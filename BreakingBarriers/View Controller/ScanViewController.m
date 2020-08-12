//
//  ScanViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/17/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "LanguageChooserViewController.h"
#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
@import MLKit;

static NSString *const sessionQueueLabel = @"com.google.mlkit.visiondetector.SessionQueue";
static NSString *const videoDataOutputQueueLabel =
@"com.google.mlkit.visiondetector.VideoDataOutputQueue";

@interface ScanViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, LanguageChooserViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *translatedLabel;
@property (weak, nonatomic) IBOutlet UIButton *languageButton;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCapturePhotoOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) UIView *overlayView;
@property(nonatomic) CMSampleBufferRef lastFrame;
@property(nonatomic) dispatch_queue_t sessionQueue;
@property (strong, nonatomic) NSString *targetLanguage;
@property (strong, nonatomic) NSString *sourceLangauge;
@property(nonatomic, strong) MLKTranslator *translator;
@property CGFloat viewHeight;
@property CGFloat viewWidth;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sessionQueue = dispatch_queue_create(sessionQueueLabel.UTF8String, nil);
    self.captureSession = [[AVCaptureSession alloc] init];
    [self setUpCaptureSessionInput];
    [self setUpCaptureSessionOutput];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupLivePreview];
    [self startSession];
}

- (void)setupLivePreview {
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    if(self.videoPreviewLayer) {
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.backgroundColor = UIColor.blackColor.CGColor;
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        self.videoPreviewLayer.frame = self.previewView.bounds;
        [self.previewView.layer addSublayer: self.videoPreviewLayer];
        self.viewHeight = self.previewView.frame.size.height;
        self.viewWidth = self.previewView.frame.size.width;
        [self setUpPreviewOverlayView];
    }
}

- (void)setUpCaptureSessionOutput {
  dispatch_async(_sessionQueue, ^{
    [self->_captureSession beginConfiguration];
    // When performing latency tests to determine ideal capture settings,
    // run the app in 'release' mode to get accurate performance metrics
    self->_captureSession.sessionPreset = AVCaptureSessionPresetMedium;

    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.videoSettings = @{
      (id)
      kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
    };
    output.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t outputQueue = dispatch_queue_create(videoDataOutputQueueLabel.UTF8String, nil);
    [output setSampleBufferDelegate:self queue:outputQueue];
    if ([self.captureSession canAddOutput:output]) {
      [self.captureSession addOutput:output];
      [self.captureSession commitConfiguration];
    } else {
      NSLog(@"%@", @"Failed to add capture session output.");
    }
  });
}

- (void)setUpCaptureSessionInput {
  dispatch_async(_sessionQueue, ^{
    AVCaptureDevicePosition cameraPosition = AVCaptureDevicePositionBack;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
      [self->_captureSession beginConfiguration];
      NSArray<AVCaptureInput *> *currentInputs = self.captureSession.inputs;
      for (AVCaptureInput *input in currentInputs) {
        [self.captureSession removeInput:input];
      }
      NSError *error;
      AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                          error:&error];
      if (error) {
        NSLog(@"Failed to create capture device input: %@", error.localizedDescription);
        return;
      } else {
        if ([self.captureSession canAddInput:input]) {
          [self.captureSession addInput:input];
        } else {
          NSLog(@"%@", @"Failed to add capture session input.");
        }
      }
      [self.captureSession commitConfiguration];
    } else {
      NSLog(@"Failed to get capture device for camera position: %ld", cameraPosition);
    }
  });
}

- (void)startSession {
  dispatch_async(_sessionQueue, ^{
    [self->_captureSession startRunning];
  });
}

- (void)stopSession {
  dispatch_async(_sessionQueue, ^{
    [self->_captureSession stopRunning];
  });
}

- (void)setUpPreviewOverlayView {
    self.overlayView = [[UIView alloc] initWithFrame:self.videoPreviewLayer.frame];
    self.overlayView.layer.backgroundColor = UIColor.blackColor.CGColor;
    self.overlayView.alpha = .3;
    [self.previewView addSubview:self.overlayView];
    CGRect rect = CGRectMake(self.previewView.frame.size.width / 2 - 125, self.previewView.frame.size.height / 2 - 50, 250, 100);
    [self addRectangle:rect toView:self.previewView color:UIColor.clearColor];
}

- (void)addRectangle:(CGRect)rectangle toView:(UIView *)view color:(UIColor *)color {
    UIView *rectangleView = [[UIView alloc] initWithFrame:rectangle];
    rectangleView.layer.cornerRadius = 10;
    rectangleView.layer.borderColor = [UIColor whiteColor].CGColor;
    rectangleView.layer.borderWidth = 3;
    rectangleView.backgroundColor = color;
    [view addSubview:rectangleView];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self stopSession];
}

- (void)recognizeText:(MLKVisionImage *)image {
    MLKTextRecognizer *textRecognizer = [MLKTextRecognizer textRecognizer];
    [textRecognizer processImage:image completion:^(MLKText * _Nullable text, NSError * _Nullable error) {
        if (error != nil || text == nil) {
            NSLog(@"Error");
            return;
        }
        NSString *resultText = text.blocks.firstObject.text;
        self.resultLabel.text = resultText;
        [self recognizeLanguage:resultText];
        NSLog(@"%@", resultText);
    }];
}

- (void)recognizeLanguage:(NSString *)text {
    MLKLanguageIdentification *languageId = [MLKLanguageIdentification languageIdentification];
    [languageId identifyLanguageForText:text completion:^(NSString * _Nullable languageTag, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Failed with error in recognize language: %@", error.localizedDescription);
            return;
          }
          if (![languageTag isEqualToString:@"und"] ) {
              NSLog(@"Identified Language: %@", languageTag);
              dispatch_async(dispatch_get_main_queue(), ^(void){
                  self.sourceLangauge = languageTag;
                  self.languageLabel.text = [NSLocale.currentLocale localizedStringForLanguageCode:languageTag];
              });
              [self translate:text];
          } else {
            NSLog(@"No source language was identified");
          }
    }];
}

- (void)translate:(NSString *)text {
    NSLog(@"Source language: %@", self.languageLabel.text);
    MLKTranslatorOptions *options = [[MLKTranslatorOptions alloc] initWithSourceLanguage:self.sourceLangauge targetLanguage:self.targetLanguage];
    self.translator = [MLKTranslator translatorWithOptions:options];
    [self.translator downloadModelIfNeededWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            return;
          }
        [self.translator translateText:text completion:^(NSString *_Nullable result, NSError *_Nullable error) {
            if (error != nil) {
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                self.translatedLabel.text = result;
            });
        }];
                
    }];
}
- (IBAction)chooseLanguage:(id)sender {
    [self performSegueWithIdentifier:@"languageChooser" sender:sender];
}

- (void)languageChooserViewController:(LanguageChooserViewController *)contoller didPickLanguage:(NSString *)language {
    self.targetLanguage = language;
    [self.languageButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer options:nil];
    CIContext *context = CIContext.context;
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:[ciImage extent]];
    return [UIImage imageWithCGImage:cgImage];
}

- (UIImage*) cropImage:(UIImage*)inputImage toRect:(CGRect)cropRect viewWidth:(CGFloat)viewWidth viewHeight:(CGFloat)viewHeight
{
    // viewWidth, viewHeight are dimensions of imageView
    const CGFloat imageViewScale = MAX(inputImage.size.width/ viewWidth, inputImage.size.height/ viewHeight);

    // Scale cropRect to handle images larger than shown-on-screen size
    cropRect.origin.x = cropRect.origin.x * imageViewScale;
    cropRect.origin.y = cropRect.origin.y * imageViewScale;
    cropRect.size.width = cropRect.size.width * imageViewScale;
    cropRect.size.height = cropRect.size.height * imageViewScale;
    
    // Perform cropping in Core Graphics
    CGImageRef cutImageRef = CGImageCreateWithImageInRect(inputImage.CGImage, cropRect);
    
    // Convert back to UIImage
    UIImage* croppedImage = [UIImage imageWithCGImage:cutImageRef];
    
    // Clean up reference pointers
    CGImageRelease(cutImageRef);
    
    return croppedImage;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    NSLog(@"%f", image.size.height);
    NSLog(@"%f", image.size.width);
    //CGRect crop = CGRectMake(112.5, image.size.height / 2 - 50, 250, 100);
    CGRect crop = CGRectMake(image.size.width / 2 - 500, image.size.height / 2 - 50, 1000, 100);
    UIImage *new = [self cropImage:image toRect:crop viewWidth:self.viewWidth viewHeight:self.viewHeight];
    if (new) {
        MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:new];
        visionImage.orientation = UIImageOrientationRight;
        [self recognizeText:visionImage];
    } else {
        NSLog(@"%@", @"Failed to get image buffer from sample buffer.");
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navController = segue.destinationViewController;
    LanguageChooserViewController *controller = navController.topViewController;
    controller.delegate = self;
}


@end

//
//  ScanViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/17/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
@import MLKit;

@interface ScanViewController ()
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCapturePhotoOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) UIView *overlayView;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.captureSession = [AVCaptureSession new];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!backCamera) {
        NSLog(@"Unable to access back camera");
        return;
    }
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    if (!error) {
        self.stillImageOutput = [AVCapturePhotoOutput new];

        if ([self.captureSession canAddInput:input] && [self.captureSession canAddOutput:self.stillImageOutput]) {
            
            [self.captureSession addInput:input];
            [self.captureSession addOutput:self.stillImageOutput];
            [self setupLivePreview];
            [self setUpPreviewOverlayView];
        }
    } else {
        NSLog(@"Error Unable to initialize back camera: %@", error.localizedDescription);
    }
}

- (void)setupLivePreview {
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    if(self.videoPreviewLayer) {
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.backgroundColor = UIColor.blackColor.CGColor;
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        self.previewView.layer.masksToBounds = YES;
        self.videoPreviewLayer.frame = self.previewView.bounds;
        [self.previewView.layer addSublayer: self.videoPreviewLayer];
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            [self.captureSession startRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoPreviewLayer.frame = self.previewView.bounds;
            });
        });
    }
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.captureSession stopRunning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

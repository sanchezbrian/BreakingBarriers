//
//  ConversationViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/15/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "ConversationViewController.h"
#import "LanguageChooserViewController.h"
#import "PulsingHaloLayer.h"
@import MLKit;

@interface ConversationViewController () <LanguageChooserViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *conversationOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *conversationTwoLabel;
@property (weak, nonatomic) IBOutlet UIButton *languageOneButton;
@property (weak, nonatomic) IBOutlet UIButton *languageTwoButton;
@property (weak, nonatomic) IBOutlet UIButton *micOneButton;
@property (weak, nonatomic) IBOutlet UIButton *micTwoButton;
@property (weak, nonatomic) IBOutlet UIView *viewOne;
@property (weak, nonatomic) IBOutlet UIView *viewTwo;
@property (weak, nonatomic) IBOutlet UIView *buttonTwoView;

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) MLKTranslator *translator;
@property (nonatomic, strong) NSArray<MLKTranslateLanguage> *allLanguages;
@property (nonatomic, strong) NSString *langOne;
@property (nonatomic, strong) NSString *langTwo;
@property (nonatomic, strong) PulsingHaloLayer *haloOne;
@property (nonatomic, strong) PulsingHaloLayer *haloTwo;
@property CGPoint viewTwoStartPoint;
@property (assign, nonatomic) BOOL startPoint;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.speechRecognizer.delegate = self;
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"Authorized");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"Denied");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                NSLog(@"Not Determined");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"Restricted");
                break;
            default:
                break;
        }
    }];
    self.startPoint = YES;

    if ([PFUser currentUser] != nil) {
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSString *language = [defaults stringForKey:@"default_language_one"];
//        NSString *languageTwo = [defaults stringForKey:@"default_language_two"];
//        self.langOne = language;
//        self.langTwo = languageTwo;
//        if (self.langOne != nil) {
//            [self.languageOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
//            [self.languageTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:languageTwo] forState:UIControlStateNormal];
//             //self.conversationOneLabel.text = @"Tap mic to speak";
//            }
    }
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.startPoint) {
        self.viewTwoStartPoint = self.viewTwo.frame.origin;
        self.startPoint = NO;
    }
    self.viewOne.layer.cornerRadius = 30;
    self.viewTwo.layer.cornerRadius = 30;
    self.languageOneButton.layer.cornerRadius = 10;
    self.languageTwoButton.layer.cornerRadius = 10;
    self.buttonTwoView.layer.cornerRadius = 20;
    [self.languageOneButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.languageOneButton.layer setShadowOffset:CGSizeMake(-1, -1)];
    [self.languageOneButton.layer setShadowRadius:1.0];
    [self.languageOneButton.layer setShadowOpacity:0.5];
    self.languageOneButton.clipsToBounds = false;
    self.languageOneButton.layer.masksToBounds = false;
    [self.languageTwoButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.languageTwoButton.layer setShadowOffset:CGSizeMake(-1, -1)];
    [self.languageTwoButton.layer setShadowRadius:1.0];
    [self.languageTwoButton.layer setShadowOpacity:0.5];
    self.languageTwoButton.clipsToBounds = false;
    self.languageTwoButton.layer.masksToBounds = false;
    self.viewOne.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.viewTwo.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.viewTwo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.viewOne setTranslatesAutoresizingMaskIntoConstraints:NO];
    CGRect frame = self.viewTwo.frame;
    frame.origin = self.viewTwoStartPoint;
    frame.size.height = self.view.frame.size.height - self.viewTwoStartPoint.y - 20;
    self.viewTwo.frame = frame;
    if ([PFUser currentUser] != nil) {
    PFUser *user = [PFUser currentUser];
        if (user[@"sourceLang"] != nil && user[@"targetLang"]) {
            [self.languageOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:user[@"sourceLang"]] forState:UIControlStateNormal];
            [self.languageTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:user[@"targetLang"]] forState:UIControlStateNormal];
            self.langOne = user[@"sourceLang"];
            self.langTwo = user[@"targetLang"];
        }
    }
}

- (void)startListen:(UILabel *)label to:(UILabel *)labelTo source:(NSString *)source target:(NSString *) target {
    self.audioEngine = [[AVAudioEngine alloc] init];
    
    // checking if there is a recognition task in progress
    if (self.recognitionTask) {
        [self. recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    self.recognitionRequest.shouldReportPartialResults = YES;
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Whatever you say in the microphone after pressing the button should be being logged
            // in the console.
            NSLog(@"RESULT:%@",result.bestTranscription.formattedString);
            label.text = result.bestTranscription.formattedString;
            [self translate:label to:labelTo source:source target:target];
            isFinal = !result.isFinal;
        }
        if (error) {
            [self.audioEngine stop];
            [inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
        }
    }];
    
    // Sets the recording format
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];

    // Starts the audio engine, i.e. it starts listening.
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    NSLog(@"Say Something, I'm listening");
}
- (IBAction)pressMicOne:(id)sender {
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        [self speakText:self.conversationTwoLabel.text withLanguage:self.langTwo];
        [UIView transitionWithView:self.micOneButton
          duration:0.3
           options:UIViewAnimationOptionTransitionCrossDissolve
        animations:^{
            [self.micOneButton setSelected:NO];
            [self.haloOne removeFromSuperlayer];
        } completion:nil];
    } else {
        self.conversationOneLabel.text = @"Listening...";
        self.conversationTwoLabel.text = @"";
        [self SpeechLanguage:self.langOne];
        [self startListen:self.conversationOneLabel to:self.conversationTwoLabel source:self.langOne target:self.langTwo];
        [UIView transitionWithView:self.micOneButton
          duration:0.3
           options:UIViewAnimationOptionTransitionCrossDissolve
        animations:^{
            [self.micOneButton setSelected:YES];
            [self startHaloOne];
        } completion:nil];
    }
}
- (IBAction)pressMicTwo:(id)sender {
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        [self speakText:self.conversationOneLabel.text withLanguage:self.langOne];
        [UIView transitionWithView:self.micTwoButton
          duration:0.3
           options:UIViewAnimationOptionTransitionCrossDissolve
        animations:^{
            [self.micTwoButton setSelected:NO];
            [self.haloTwo removeFromSuperlayer];
        } completion:nil];
    } else {
        self.conversationTwoLabel.text = @"Listening...";
        self.conversationOneLabel.text = @"";
        [self SpeechLanguage:self.langTwo];
        [self startListen:self.conversationTwoLabel to:self.conversationOneLabel source:self.langTwo target:self.langOne];
        [UIView transitionWithView:self.micTwoButton
          duration:0.3
           options:UIViewAnimationOptionTransitionCrossDissolve
        animations:^{
            [self.micTwoButton setSelected:YES];
            [self startHaloTwo];
        } completion:nil];
    }
}

- (void)startHaloOne {
    self.haloOne = [PulsingHaloLayer layer];
    self.haloOne.radius = 55;
    self.haloOne.haloLayerNumber = 3;
    self.haloOne.position = CGPointMake(self.micOneButton.layer.bounds.size.width / 2, self.micOneButton.layer.bounds.size.height / 2);
    [self.micOneButton.layer addSublayer:self.haloOne];
    UIColor *colorOne = [UIColor colorWithRed:110.0 / 255 green:198.0 / 255 blue:1 alpha:1.0];
    self.haloOne.backgroundColor = colorOne.CGColor;
    [self.haloOne start];
}

- (void)startHaloTwo {
    self.haloTwo = [PulsingHaloLayer layer];
    self.haloTwo.radius = 55;
    self.haloTwo.haloLayerNumber = 3;
    self.haloTwo.position = CGPointMake(self.micTwoButton.layer.bounds.size.width / 2, self.micTwoButton.layer.bounds.size.height / 2);
    [self.micTwoButton.layer addSublayer:self.haloTwo];
    UIColor *colorTwo = [UIColor colorWithRed:1 green:221.0 / 255 blue: 113.0 / 255 alpha:1.0];
    self.haloTwo.backgroundColor = colorTwo.CGColor;
    [self.haloTwo start];
}

- (void)speakText:(NSString *)text withLanguage:(NSString *)language {
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:language];
    utterance.rate = 0.45f;
    AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
    [syn speakUtterance:utterance];
}

- (void)SpeechLanguage:(NSString *)language {
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:language]];
}

- (void)translate:(UILabel *)label to:(UILabel *)labelTo source:(NSString *)source target:(NSString *) target {
    MLKTranslatorOptions *options = [[MLKTranslatorOptions alloc] initWithSourceLanguage:source targetLanguage:target];
    self.translator = [MLKTranslator translatorWithOptions:options];
    [self.translator downloadModelIfNeededWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            labelTo.text =
                [NSString stringWithFormat:@"Failed to ensure model downloaded with error %@",
                                           error.localizedDescription];
            return;
          }
          NSString *text = label.text;
          if (text == nil) {
            text = @"";
          }
          labelTo.text = @"";
          [self.translator translateText:text
                              completion:^(NSString *_Nullable result, NSError *_Nullable error) {
                                if (error != nil) {
                                  labelTo.text = [NSString
                                      stringWithFormat:@"Failed to ensure model downloaded with error %@",
                                                       error.localizedDescription];
                                  return;
                                }
                                labelTo.text = result;
          }];
        }];
}
- (IBAction)changeLangOne:(id)sender {
    [self performSegueWithIdentifier:@"chooseLanguage" sender:sender];
}

- (IBAction)changeLangTwo:(id)sender {
    [self performSegueWithIdentifier:@"chooseLanguage" sender:sender];
}

- (void)languageChooserViewController:(LanguageChooserViewController *)contoller didPickLanguage:(NSString *)language {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (contoller.langOne) {
        self.langOne = language;
        [self.languageOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        self.conversationOneLabel.text = @"Tap mic to speak";
        self.conversationTwoLabel.text = @"Tap mic to speak";
        if ([PFUser currentUser] != nil) {
            PFUser *currUser = [PFUser currentUser];
            currUser[@"sourceLang"] = language;
            [currUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error) {
                    NSLog(@"Error: %@", error.localizedDescription);
                } else {
                    NSLog(@"Edit was successful");
                }
            }];
           //[defaults setObject:language forKey:@"default_language_one"];
        }
        NSLog(@"Language 1: %@", language);
    } else {
        self.langTwo = language;
        [self.languageTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        self.conversationTwoLabel.text = @"Tap mic to speak";
        self.conversationOneLabel.text = @"Tap mic to speak";
        if ([PFUser currentUser] != nil) {
            PFUser *currUser = [PFUser currentUser];
            currUser[@"targetLang"] = language;
            [currUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error) {
                    NSLog(@"Error: %@", error.localizedDescription);
                } else {
                    NSLog(@"Edit was successful");
                }
            }];
           //[defaults setObject:language forKey:@"default_language_two"];
        }
        NSLog(@"Language 2: %@", language);
    }
    [defaults synchronize];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navController = segue.destinationViewController;
    LanguageChooserViewController *controller = navController.topViewController;
    controller.delegate = self;
    if ([sender tag] == 1) {
        controller.langOne = YES;
    } else {
        controller.langTwo = YES;
    }
}
- (IBAction)tapViewOne:(UITapGestureRecognizer *)sender {
    if (CGPointEqualToPoint(self.viewTwo.frame.origin, self.viewTwoStartPoint)) {
        [UIView animateWithDuration:.3 animations:^{
            self.viewTwo.transform = CGAffineTransformMakeTranslation(0, 150);
            CGRect frame = self.viewTwo.frame;
            frame.size.height = self.view.frame.size.height - self.viewTwoStartPoint.y - 170;
            self.viewTwo.frame = frame;
            [self.viewTwo layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:.3 animations:^{
            self.viewTwo.transform = CGAffineTransformMakeTranslation(0, 0);
            CGRect frame = self.viewTwo.frame;
            frame.origin = self.viewTwoStartPoint;
            frame.size.height = self.view.frame.size.height - self.viewTwoStartPoint.y - 20;
            self.viewTwo.frame = frame;
            [self.viewTwo layoutIfNeeded];
        }];
    }
}
- (IBAction)tapViewtwo:(UITapGestureRecognizer *)sender {
    if (CGPointEqualToPoint(self.viewTwo.frame.origin, self.viewTwoStartPoint)) {
        [UIView animateWithDuration:.3 animations:^{
            self.viewTwo.transform = CGAffineTransformMakeTranslation(0, -150);
            CGRect frame = self.viewTwo.frame;
            frame.size.height = self.view.frame.size.height - self.viewTwo.frame.origin.y - 20;
            self.viewTwo.frame = frame;
            [self.viewTwo layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:.3 animations:^{
            self.viewTwo.transform = CGAffineTransformMakeTranslation(0, 0);
            CGRect frame = self.viewTwo.frame;
            frame.origin = self.viewTwoStartPoint;
            frame.size.height = self.view.frame.size.height - self.viewTwoStartPoint.y - 20;
            self.viewTwo.frame = frame;
            [self.viewTwo layoutIfNeeded];
        }];
    }
}


@end

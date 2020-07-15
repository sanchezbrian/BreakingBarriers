//
//  ConversationViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/15/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "ConversationViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "LanguageChooserViewController.h"
@import MLKit;

@interface ConversationViewController () <LanguageChooserViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *conversationOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *conversationTwoLabel;
@property (weak, nonatomic) IBOutlet UIButton *languageOneButton;
@property (weak, nonatomic) IBOutlet UIButton *languageTwoButton;
@property (weak, nonatomic) IBOutlet UIButton *micOneButton;
@property (weak, nonatomic) IBOutlet UIButton *micTwoButton;

@property(nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property(nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property(nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property(nonatomic, strong) AVAudioEngine *audioEngine;
@property(nonatomic, strong) MLKTranslator *translator;
@property(nonatomic, strong) NSArray<MLKTranslateLanguage> *allLanguages;
@property(nonatomic, strong) NSString *langOne;
@property(nonatomic, strong) NSString *langTwo;

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
    NSLocale *currentLocale = NSLocale.currentLocale;
    self.allLanguages = [MLKTranslateAllLanguages().allObjects
    sortedArrayUsingComparator:^NSComparisonResult(NSString *_Nonnull lang1,
                                                   NSString *_Nonnull lang2) {
      return [[currentLocale localizedStringForLanguageCode:lang1]
          compare:[currentLocale localizedStringForLanguageCode:lang2]];
    }];
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
    } else {
        [self SpeechLanguage:self.langOne];
        [self startListen:self.conversationOneLabel to:self.conversationTwoLabel source:self.langOne target:self.langTwo];
    }
}
- (IBAction)pressMicTwo:(id)sender {
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        [self speakText:self.conversationOneLabel.text withLanguage:self.langOne];
    } else {
        [self SpeechLanguage:self.langTwo];
        [self startListen:self.conversationTwoLabel to:self.conversationOneLabel source:self.langTwo target:self.langOne];
    }
}

- (void)speakText:(NSString *)text withLanguage:(NSString *)language {
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:language];
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
            // self.conversationTwoLabel.text
            labelTo.text =
                [NSString stringWithFormat:@"Failed to ensure model downloaded with error %@",
                                           error.localizedDescription];
            return;
          }
                    //self.conversationOneLabel.text
          NSString *text = label.text;
          if (text == nil) {
            text = @"";
          }
            // self.conversationTwoLabel.text
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
    if (contoller.langOne) {
        self.langOne = language;
        [self.languageOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        NSLog(@"Language 1: %@", language);
    } else {
        self.langTwo = language;
        [self.languageTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        NSLog(@"Language 2: %@", language);
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
    if ([sender tag] == 1) {
        controller.langOne = YES;
    } else {
        controller.langTwo = YES;
    }
}


@end

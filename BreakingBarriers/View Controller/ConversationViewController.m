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

@interface ConversationViewController ()
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

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
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

- (void)startListen {
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
            self.conversationOneLabel.text = result.bestTranscription.formattedString;
            [self translate];
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
        NSError *error;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.conversationTwoLabel.text];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"es"];
        AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
        [syn speakUtterance:utterance];
    } else {
        [self startListen];
    }
}

- (void)translate {
    MLKTranslatorOptions *options = [[MLKTranslatorOptions alloc] initWithSourceLanguage:MLKTranslateLanguageEnglish targetLanguage:MLKTranslateLanguageSpanish];
    self.translator = [MLKTranslator translatorWithOptions:options];
    [self.translator downloadModelIfNeededWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            self.conversationTwoLabel.text =
                [NSString stringWithFormat:@"Failed to ensure model downloaded with error %@",
                                           error.localizedDescription];
            return;
          }
          NSString *text = self.conversationOneLabel.text;
          if (text == nil) {
            text = @"";
          }
          self.conversationTwoLabel.text = @"";
          [self.translator translateText:text
                              completion:^(NSString *_Nullable result, NSError *_Nullable error) {
                                if (error != nil) {
                                  self.conversationTwoLabel.text = [NSString
                                      stringWithFormat:@"Failed to ensure model downloaded with error %@",
                                                       error.localizedDescription];
                                  return;
                                }
                                self.conversationTwoLabel.text = result;
                              }];
        }];
}
- (IBAction)changeLangOne:(id)sender {
    [self performSegueWithIdentifier:@"chooseLanguage" sender:sender];
}
- (IBAction)changeLangTwo:(id)sender {
    [self performSegueWithIdentifier:@"chooseLanguage" sender:sender];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end

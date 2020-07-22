//
//  TranslateViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/16/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//
@import MLKit;
#import "LanguageChooserViewController.h"
#import <Parse/Parse.h>
#import "SavedText.h"
#import "TranslateViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TranslateViewController () <LanguageChooserViewControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *langOneButton;
@property (weak, nonatomic) IBOutlet UIButton *langTwoButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property(nonatomic, strong) MLKTranslator *translator;
@property (strong, nonatomic) NSString *langOne;
@property (strong, nonatomic) NSString *langTwo;

@end

@implementation TranslateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.outputLabel.alpha = 0;
    self.sourceTextField.delegate = self;
    self.sourceTextField.returnKeyType = UIReturnKeyDone;
    [self.sourceTextField setBorderStyle:UITextBorderStyleNone];
    self.sourceTextField.layer.borderWidth = 1;
    self.sourceTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (void)textFieldDidChangeSelection:(UITextField *)textField {
    [UILabel animateWithDuration:.2 animations:^{
        self.outputLabel.alpha = 1;
    }];
    [self translate];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
     if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
      }
      return YES;
}

- (void)translate {
    MLKTranslatorOptions *options = [[MLKTranslatorOptions alloc] initWithSourceLanguage:self.langOne targetLanguage:self.langTwo];
    self.translator = [MLKTranslator translatorWithOptions:options];
    [self.translator downloadModelIfNeededWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            self.outputLabel.text =
                [NSString stringWithFormat:@"Failed to ensure model downloaded with error %@",
                                           error.localizedDescription];
            return;
          }
        NSString *text = self.sourceTextField.text;
          if (text == nil) {
            text = @"";
          }
        self.outputLabel.text = @"";
          [self.translator translateText:text completion:^(NSString *_Nullable result, NSError *_Nullable error) {
              if (error != nil) {
                  self.outputLabel.text = [NSString stringWithFormat:@"Failed to ensure model downloaded with error %@", error.localizedDescription];
                  return;
              }
              [self checkPhrase:self.sourceTextField.text];
              self.outputLabel.text = result;
          }];
    }];
}

- (void)checkPhrase:(NSString *)text {
    NSLog(@"%@", text);
    PFQuery *query = [PFQuery queryWithClassName:@"SavedText"];
    [query whereKey:@"sourceText" equalTo:text];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSLog(@"%@", objects);
        if (objects.count == 1) {
            [self.saveButton setSelected:YES];
        } else {
            [self.saveButton setSelected:NO];
        }
    }];
}

- (IBAction)changeLangOne:(id)sender {
    [self performSegueWithIdentifier:@"languagePicker" sender:sender];
}
- (IBAction)changeLangTwo:(id)sender {
    [self performSegueWithIdentifier:@"languagePicker" sender:sender];
}
- (IBAction)switchButton:(id)sender {
    NSString *temp = self.langOne;
    self.langOne = self.langTwo;
    self.langTwo = temp;
    [self.langOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:self.langOne] forState:UIControlStateNormal];
    [self.langTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:self.langTwo] forState:UIControlStateNormal];
}

- (void)languageChooserViewController:(LanguageChooserViewController *)contoller didPickLanguage:(NSString *)language {
    if (contoller.langOne) {
        self.langOne = language;
        [self.langOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        NSLog(@"Language 1: %@", language);
    } else {
        self.langTwo = language;
        [self.langTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        NSLog(@"Language 2: %@", language);
    }
}
- (IBAction)pressSave:(id)sender {
    [SavedText postSavedText:self.sourceTextField.text withOutputText:self.outputLabel.text sourceLanguage:self.langOne outputLanguage:self.langTwo withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error posting: %@", error.localizedDescription);
        } else {
            NSLog(@"Post was successful");
            [self.saveButton setSelected:YES];
        }
    }];
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

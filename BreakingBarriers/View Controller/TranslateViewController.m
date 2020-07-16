//
//  TranslateViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/16/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "TranslateViewController.h"
#import "LanguageChooserViewController.h"
@import MLKit;

@interface TranslateViewController () <LanguageChooserViewControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *langOneButton;
@property (weak, nonatomic) IBOutlet UIButton *langTwoButton;
@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property(nonatomic, strong) MLKTranslator *translator;
@property (strong, nonatomic) NSString *langOne;
@property (strong, nonatomic) NSString *langTwo;

@end

@implementation TranslateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sourceTextField.delegate = self;
    self.sourceTextField.returnKeyType = UIReturnKeyDone;
}

- (void)textFieldDidChangeSelection:(UITextField *)textField {
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
          [self.translator translateText:text
                              completion:^(NSString *_Nullable result, NSError *_Nullable error) {
                                if (error != nil) {
                                  self.outputLabel.text = [NSString
                                      stringWithFormat:@"Failed to ensure model downloaded with error %@",
                                                       error.localizedDescription];
                                  return;
                                }
                                self.outputLabel.text = result;
                              }];
        }];
}

- (IBAction)changeLangOne:(id)sender {
    [self performSegueWithIdentifier:@"languagePicker" sender:sender];
}
- (IBAction)changeLangTwo:(id)sender {
    [self performSegueWithIdentifier:@"languagePicker" sender:sender];
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

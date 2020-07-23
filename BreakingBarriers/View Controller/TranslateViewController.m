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

@interface TranslateViewController () <LanguageChooserViewControllerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *langOneButton;
@property (weak, nonatomic) IBOutlet UIButton *langTwoButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property(nonatomic, strong) MLKTranslator *translator;
@property (strong, nonatomic) NSString *langOne;
@property (strong, nonatomic) NSString *langTwo;

@end

@implementation TranslateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.outputLabel.alpha = 0;
    self.saveButton.alpha = 0;
    self.textView.delegate = self;
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.borderWidth = 2;
    self.textView.text = @"Please type here...";
    self.textView.textColor = [UIColor lightGrayColor];
}

#pragma mark - TextView Delegate
- (void)textViewDidChange:(UITextView *)textView {
    [UILabel animateWithDuration:.2 animations:^{
        self.outputLabel.alpha = 1;
        self.saveButton.alpha = 1;
    }];
    [self translate];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Please type here..."]) {
         textView.text = @"";
         textView.textColor = [UIColor blackColor]; //optional
    }
    if (self.langOne == nil) {
        [self checkIfLangugeChosen: 0];
    } else if (self.langTwo == nil) {
        [self checkIfLangugeChosen: 1];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Please type here...";
        textView.textColor = [UIColor lightGrayColor]; //optional
        [UILabel animateWithDuration:.2 animations:^{
            self.outputLabel.alpha = 0;
            self.saveButton.alpha = 0;
        }];
    }
    [textView resignFirstResponder];
}

#pragma mark - LanguageChooserController Delegate
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

#pragma mark - Helper Methdods
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
        NSString *text = self.textView.text;
          if (text == nil) {
            text = @"";
          }
        self.outputLabel.text = @"";
          [self.translator translateText:text completion:^(NSString *_Nullable result, NSError *_Nullable error) {
              if (error != nil) {
                  self.outputLabel.text = [NSString stringWithFormat:@"Failed to ensure model downloaded with error %@", error.localizedDescription];
                  return;
              }
              [self checkPhrase:self.textView.text];
              self.outputLabel.text = result;
          }];
    }];
}

- (void)checkPhrase:(NSString *)text {
    PFQuery *query = [PFQuery queryWithClassName:@"SavedText"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query whereKey:@"sourceText" equalTo:text];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count == 1) {
            [self.saveButton setSelected:YES];
        } else {
            [self.saveButton setSelected:NO];
        }
    }];
}

- (void)checkIfLangugeChosen:(int)num {
    if (num == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Source Language Required" message:@"Please choose a source language" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"languagePicker" sender:self.langOneButton];
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
            // optional code for what happens after the alert controller has finished presenting
        }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Target Language Required" message:@"Please choose a target language" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"languagePicker" sender:self.langTwoButton];
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
            // optional code for what happens after the alert controller has finished presenting
        }];
    }
}

#pragma mark - Buttons

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

- (IBAction)pressSave:(id)sender {
    if (self.saveButton.selected) {
        PFQuery *query = [PFQuery queryWithClassName:@"SavedText"];
        [query includeKey:@"author"];
        [query whereKey:@"author" equalTo:[PFUser currentUser]];
        [query whereKey:@"sourceText" equalTo:self.textView.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [PFObject deleteAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                NSLog(@"Sucessfully deleted!");
                [self.saveButton setSelected:NO];
            }];
        }];
    } else {
        [SavedText postSavedText:self.textView.text withOutputText:self.outputLabel.text sourceLanguage:self.langOne outputLanguage:self.langTwo withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error posting: %@", error.localizedDescription);
            } else {
                NSLog(@"Post was successful");
                [self.saveButton setSelected:YES];
            }
        }];
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

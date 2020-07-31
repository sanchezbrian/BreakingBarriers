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
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property(nonatomic, strong) MLKTranslator *translator;
@property (strong, nonatomic) NSString *langOne;
@property (strong, nonatomic) NSString *langTwo;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UILabel *targetLang;
@property (weak, nonatomic) IBOutlet UILabel *sourceLang;
@property (weak, nonatomic) IBOutlet UIView *sourceView;
@property (weak, nonatomic) IBOutlet UIView *targetView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property CGRect buttonViewStart;
@property CGRect sourceViewStart;
@property CGRect targetViewStart;

@end

@implementation TranslateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sourceLang.alpha = 0;
    self.targetLang.alpha = 0;
    self.targetView.alpha = 0;
    self.textView.delegate = self;
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.text = @"Tap to enter text";
    self.textView.textColor = [UIColor lightGrayColor];
    
    self.sourceView.layer.cornerRadius = 12;
    self.targetView.layer.cornerRadius = 12;
    [self.sourceView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.sourceView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.sourceView.layer setShadowRadius:1.0];
    [self.sourceView.layer setShadowOpacity:0.5];
    self.sourceView.clipsToBounds = false;
    self.sourceView.layer.masksToBounds = false;
    
    [self.targetView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.targetView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.targetView.layer setShadowRadius:1.0];
    [self.targetView.layer setShadowOpacity:0.5];
    self.targetView.clipsToBounds = false;
    self.targetView.layer.masksToBounds = false;

    
    UIView *border = [UIView new];
    border.backgroundColor = UIColor.systemGray5Color;
    [border setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    border.frame = CGRectMake(0, 0, self.buttonView.frame.size.width, 1);
    [self.buttonView addSubview:border];
    self.langOneButton.layer.cornerRadius = 15;
    self.langTwoButton.layer.cornerRadius = 15;
    self.switchButton.layer.cornerRadius = 15;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    self.buttonViewStart = self.buttonView.frame;
    self.targetViewStart = self.targetView.frame;
    self.sourceViewStart = self.sourceView.frame;
    NSLog(@"I changed");
}

#pragma mark - TextView Delegate
- (void)textViewDidChange:(UITextView *)textView {
    [UILabel animateWithDuration:.2 animations:^{
        self.targetView.alpha = 1;
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
    if ([textView.text isEqualToString:@"Tap to enter text"]) {
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
        textView.text = @"Tap to enter text";
        textView.textColor = [UIColor lightGrayColor]; //optional
        [UILabel animateWithDuration:.2 animations:^{
            self.targetView.alpha = 1;
        }];
    }
    [textView resignFirstResponder];
}

#pragma mark - LanguageChooserController Delegate
- (void)languageChooserViewController:(LanguageChooserViewController *)contoller didPickLanguage:(NSString *)language {
    if (contoller.langOne) {
        self.langOne = language;
        [self.langOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        self.targetLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:language];
        self.sourceLang.alpha = 1;
        NSLog(@"Language 1: %@", language);
    } else {
        self.langTwo = language;
        [self.langTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        self.sourceLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:language];
        self.targetLang.alpha = 1;
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

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:.03 animations:^{
        CGRect one = self.buttonViewStart;
        CGRect two = self.sourceViewStart;
        CGRect three = self.targetViewStart;
        two.origin.y = two.origin.y - keyboardSize.height + 30;
        three.origin.y = three.origin.y - keyboardSize.height + 30;
        one.origin.y = one.origin.y - keyboardSize.height + 30;
        self.buttonView.frame = one;
        self.sourceView.frame = two;
        self.targetView.frame = three;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:.03 animations:^{
        CGRect one = self.buttonView.frame;
        CGRect two = self.sourceViewStart;
        CGRect three = self.targetViewStart;
        one.origin = self.buttonViewStart.origin;
        two.origin = self.sourceViewStart.origin;
        three.origin = self.targetViewStart.origin;
        self.buttonView.frame = one;
        self.sourceView.frame = two;
        self.targetView.frame = three;
        [self.view layoutIfNeeded];
    }];
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

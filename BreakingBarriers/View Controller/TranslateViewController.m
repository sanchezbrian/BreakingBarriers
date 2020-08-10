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
@property CGRect ViewStart;
@property (strong, nonatomic) UIView *dictView;

@end

@implementation TranslateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.outputLabel.text = @"";
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
    if ([PFUser currentUser] == nil) {
        [self.saveButton setHidden:YES];
    } else {
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSString *language = [defaults stringForKey:@"default_language_one"];
//        NSString *languageTwo = [defaults stringForKey:@"default_language_two"];
//        self.langOne = language;
//        self.langTwo = languageTwo;
//        if (self.langOne != nil) {
//            [self.langOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
//            [self.langTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:languageTwo] forState:UIControlStateNormal];
//            self.targetLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:language];
//            self.sourceLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:languageTwo];
//            self.targetLang.alpha = 1;
//            self.sourceLang.alpha = 1;
//            }
    }
   
}

- (void)viewDidLayoutSubviews {
    self.dictView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.targetView.frame.origin.y - 25)];
    self.dictView.backgroundColor = UIColor.redColor;
    if ([PFUser currentUser] != nil) {
    PFUser *user = [PFUser currentUser];
        if (user[@"sourceLang"] != nil && user[@"targetLang"]) {
            [self.langOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:user[@"sourceLang"]] forState:UIControlStateNormal];
            [self.langTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:user[@"targetLang"]] forState:UIControlStateNormal];
            self.targetLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:user[@"sourceLang"]];
            self.sourceLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:user[@"targetLang"]];
            self.targetLang.alpha = 1;
            self.sourceLang.alpha = 1;
            self.langOne = user[@"sourceLang"];
            self.langTwo = user[@"targetLang"];
        }
    }
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

#pragma mark - TextView Delegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length >= 0) {
        [UILabel animateWithDuration:.2 animations:^{
            self.targetView.alpha = 1;
        }];
        [self translate];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        // dictionary of a word
//        if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:self.textView.text]) {
//            UIReferenceLibraryViewController* ref = [[UIReferenceLibraryViewController alloc] initWithTerm:self.textView.text];
//            [self.view addSubview:self.dictView];
//            [self addChildViewController:ref];
//            [ref didMoveToParentViewController:self];
//            ref.view.frame = self.dictView.bounds;
//            [self.dictView addSubview:ref.view];
//        }
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
    self.ViewStart = self.view.frame;
    if (self.langOne == nil) {
        [textView resignFirstResponder];
        [self checkIfLangugeChosen: 0];
    } else if (self.langTwo == nil) {
        [textView resignFirstResponder];
        [self checkIfLangugeChosen: 1];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Tap to enter text";
        textView.textColor = [UIColor lightGrayColor]; //optional
        [UILabel animateWithDuration:.2 animations:^{
            self.targetView.alpha = 0;
        }];
    }
    [textView resignFirstResponder];
}

#pragma mark - LanguageChooserController Delegate
- (void)languageChooserViewController:(LanguageChooserViewController *)contoller didPickLanguage:(NSString *)language {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (contoller.langOne) {
        self.langOne = language;
        [self.langOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        self.targetLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:language];
        self.targetLang.alpha = 1;
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
        [self.langTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:language] forState:UIControlStateNormal];
        self.sourceLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:language];
        self.sourceLang.alpha = 1;
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
           //[defaults setObject:language forKey:@"default_language_one"];
        }
        NSLog(@"Language 2: %@", language);
    }
    [defaults synchronize];
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
              self.outputLabel.text = result;
              if ([PFUser currentUser] != nil) {
                  [self checkPhrase:self.textView.text];
              }
          }];
    }];
}

- (void)checkPhrase:(NSString *)text {
    PFQuery *query = [PFQuery queryWithClassName:@"SavedText"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query whereKey:@"sourceText" equalTo:text];
    [query whereKey:@"translatedText" equalTo:self.outputLabel.text];
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
        }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Target Language Required" message:@"Please choose a target language" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"languagePicker" sender:self.langTwoButton];
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:.03 animations:^{
        CGRect rect = self.ViewStart;
        rect.origin.y = rect.origin.y - keyboardSize.height + 30;
        self.view.frame = rect;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:.03 animations:^{
        CGRect rect = self.view.frame;
        rect.origin = self.ViewStart.origin;
        self.view.frame = rect;
        [self.view layoutIfNeeded];
    }];
}



#pragma mark - Buttons

- (IBAction)changeLangOne:(id)sender {
    self.ViewStart = self.view.frame;
    [self performSegueWithIdentifier:@"languagePicker" sender:sender];
}
- (IBAction)changeLangTwo:(id)sender {
    self.ViewStart = self.view.frame;
    [self performSegueWithIdentifier:@"languagePicker" sender:sender];
}
- (IBAction)switchButton:(id)sender {
    NSString *temp = self.langOne;
    self.langOne = self.langTwo;
    self.langTwo = temp;
    self.targetLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:self.langOne];
    self.sourceLang.text = [NSLocale.currentLocale localizedStringForLanguageCode:self.langTwo];
    [self.langOneButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:self.langOne] forState:UIControlStateNormal];
    [self.langTwoButton setTitle:[NSLocale.currentLocale localizedStringForLanguageCode:self.langTwo] forState:UIControlStateNormal];
    if ([PFUser currentUser] != nil) {
        PFUser *currUser = [PFUser currentUser];
        currUser[@"sourceLang"] = self.langOne;
        currUser[@"targetLang"] = self.langTwo;
        [currUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(error) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Edit was successful");
            }
        }];
    }
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

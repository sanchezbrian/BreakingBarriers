//
//  SettingsViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 8/7/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import <Parse/PFFacebookUtils.h>
#import "LoginViewController.h"
#import "SettingsViewController.h"
#import "SceneDelegate.h"


@interface SettingsViewController ()

@property (strong, nonatomic) FBSDKLoginButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *numCards;
@property (weak, nonatomic) IBOutlet UISlider *cardSlider;
@property NSUInteger maxCards;
@property NSUInteger numberOfCards;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLoginButton];
    if ([PFUser currentUser] != nil) {
        [self querySaved];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger *numOfCards = [defaults integerForKey:@"number_of_cards"];
    if (numOfCards != nil) {
        self.numberOfCards = numOfCards;
    }
    self.cardSlider.value = self.numberOfCards;
    self.numCards.text = [NSString stringWithFormat:@"%ld", lroundf(self.cardSlider.value)];
    
    // Do any additional setup after loading the view.
}

- (void)addLoginButton {
    self.loginButton = [[FBSDKLoginButton alloc] init];
    self.loginButton.delegate = self;
    self.loginButton.permissions = @[@"public_profile", @"email"];
    self.loginButton.center = self.view.center;
    CGRect frame = CGRectMake(50, self.view.frame.size.height - 100, self.view.frame.size.width - 100, 40);
    self.loginButton.frame = frame;
    [self.view addSubview:self.loginButton];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
        NSLog(@"Login");
    if (error) {
               return NSLog(@"An Error occurred: %@", error.localizedDescription);
           }

           if (result.isCancelled) {
               return NSLog(@"Login was cancelled");
           } else {
               NSLog(@"Success. Granted permissions: %@", result.grantedPermissions);
               [PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                   if (!user) {
                       NSLog(@"Uh oh. The user cancelled the Facebook login.");
                     } else if (user.isNew) {
                       NSLog(@"User signed up and logged in through Facebook!");
                     } else {
                       NSLog(@"User logged in through Facebook!");
                     }
                       NSLog(@"%@", user );
                   }];
               }
    SceneDelegate *sceneDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *timelineTabController = [storyboard instantiateViewControllerWithIdentifier:@"initialView"];
    sceneDelegate.window.rootViewController = timelineTabController;
}

- (void)loginButtonDidLogOut:(nonnull FBSDKLoginButton *)loginButton {
    NSLog(@"Logged out");
    SceneDelegate *sceneDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
}
- (IBAction)slide:(id)sender {
    self.numCards.text = [NSString stringWithFormat:@"%ld", lroundf(self.cardSlider.value)];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:lroundf(self.cardSlider.value) forKey:@"number_of_cards"];
}

- (void)querySaved {
    NSLog(@"query");
    PFQuery *query = [PFQuery queryWithClassName:@"SavedText"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects != nil) {
            self.maxCards = [objects count];
            self.cardSlider.maximumValue = self.maxCards;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
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

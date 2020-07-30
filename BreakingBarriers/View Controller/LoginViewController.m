//
//  LoginViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/21/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "LoginViewController.h"
#import <Parse/PFFacebookUtils.h>

@interface LoginViewController ()

@property (strong, nonatomic) FBSDKLoginButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *guestButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self addLoginButton];
        //[self addGuestLogin];
    });
}

- (void)addGuestLogin {
    CGRect frame = self.guestButton.frame;
    frame.size = self.loginButton.frame.size;
    self.guestButton.frame = frame;
    
}

- (void)addLoginButton {
    self.loginButton = [[FBSDKLoginButton alloc] init];
    self.loginButton.delegate = self;
    self.loginButton.permissions = @[@"public_profile", @"email"];
    self.loginButton.center = self.view.center;
    CGRect frame = self.loginButton.frame;
    frame.origin.y = self.guestButton.frame.origin.y - 50;
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
        [self performSegueWithIdentifier:@"newSegue" sender:self];
}

- (void)loginButtonDidLogOut:(nonnull FBSDKLoginButton *)loginButton {
    NSLog(@"Logged out");
}
- (IBAction)continueAsGuest:(id)sender {
    [self performSegueWithIdentifier:@"newSegue" sender:self];
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

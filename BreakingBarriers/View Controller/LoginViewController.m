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

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self addLoginButton];
    });
}

- (void)addLoginButton {
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.delegate = self;
    loginButton.permissions = @[@"public_profile", @"email"];
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
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
                    NSLog(@"%@", user);
                }];
            }
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

- (void)loginButtonDidLogOut:(nonnull FBSDKLoginButton *)loginButton {
    NSLog(@"Logged out");
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

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
#import "SKSplashIcon.h"
#import <Parse/PFFacebookUtils.h>

@interface LoginViewController ()

@property (strong, nonatomic) SKSplashView *splashView;
@property (strong, nonatomic) FBSDKLoginButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *guestButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLoginButton];
    [self addGuestLogin];
}

- (void)viewDidLayoutSubviews {
    self.imageView.layer.cornerRadius = (self.imageView.frame.size.width) / 2;
}

- (void)addGuestLogin {
    CGRect frame = self.loginButton.frame;
    frame.origin.y = frame.origin.y + 65;
    self.guestButton.layer.cornerRadius = 3;
    self.guestButton.frame = frame;
    
}

- (void)addLoginButton {
    self.loginButton = [[FBSDKLoginButton alloc] init];
    self.loginButton.delegate = self;
    self.loginButton.permissions = @[@"public_profile", @"email"];
    self.loginButton.center = self.view.center;
    CGRect frame = CGRectMake(50, self.view.frame.size.height - 200, self.view.frame.size.width - 100, 40);
//    CGRect frame = self.loginButton.frame;
//    frame.size.width = self.view.frame.size.width - 100;
//    frame.origin.x = frame.origin.x - (self.view.frame.size.width / 2);
//    frame.origin.y = frame.origin.y + 100;
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"default_language_one"];
    [defaults removeObjectForKey:@"default_language_two"];
    [self performSegueWithIdentifier:@"newSegue" sender:self];
}

-(void)splash {
    //Twitter style splash
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"Icon-App-60x60"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = [UIColor colorWithRed:0 green:150.0 / 255 blue:1 alpha:1];
    self.splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon animationType:SKSplashAnimationTypeNone];
    self.splashView.delegate = self; //Optional -> if you want to receive updates on animation beginning/end
    self.splashView.backgroundColor = twitterColor;
    self.splashView.animationDuration = 2.5; //Optional -> set animation duration. Default: 1s
    [self.view addSubview:self.splashView];
    self.navigationController.navigationBar.hidden = YES;
    [self.splashView startAnimation];
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

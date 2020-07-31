//
//  ParentViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/29/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

@import HMSegmentedControl;
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "ParentViewController.h"
#import "SceneDelegate.h"

@interface ParentViewController ()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *controllerView;
@property (strong, nonatomic) HMSegmentedControl* segmentedControl;

@end

@implementation ParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([FBSDKAccessToken currentAccessToken] == nil) {
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Conversation", @"Translate", @"Scan"]];
    } else {
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Conversation", @"Translate", @"Scan", @"Saved", @"Learn"]];
    }
    
    self.vcArray = [NSMutableArray new];
    self.title = @"Breaking Barriers";
    //self.navigationController.navigationBar.prefersLargeTitles = YES;

    self.view.backgroundColor = [UIColor whiteColor];
       
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    self.segmentedControl.frame = CGRectMake(0, 95, viewWidth, 40);
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationBottom;
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:33.0 / 255 green:150.0 / 255 blue:243.0 / 255 alpha:1];
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 5, 0, 5);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorHeight = 3;
    self.segmentedControl.verticalDividerEnabled = YES;
    self.segmentedControl.verticalDividerColor = [UIColor clearColor];
    self.segmentedControl.verticalDividerWidth = 1.0f;
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
           NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{
               NSForegroundColorAttributeName : [UIColor lightGrayColor],
               NSFontAttributeName : [UIFont systemFontOfSize:14]
           }];
           return attString;
       }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    [self displayCurrentTab:0];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.currentViewController viewDidDisappear:animated];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %tu (via UIControlEventValueChanged)", segmentedControl.selectedSegmentIndex);
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    [self displayCurrentTab:self.segmentedControl.selectedSegmentIndex];
}

- (void)displayCurrentTab:(NSInteger )index {
    UIViewController * vc = [self viewControllerForSelectedSegementIndex:index];
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    vc.view.frame = self.controllerView.bounds;
    [self.controllerView addSubview:vc.view];
    self.currentViewController = vc;
    
}

- (UIViewController *)viewControllerForSelectedSegementIndex:(NSUInteger )index {
    UIViewController *vc;
    switch (index) {
        case 0:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationController"];
            break;
        case 1:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TranslateController"];
            break;
        case 2:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanController"];
            break;
        case 3:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SavedController"];
            break;
        case 4:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LearnController"];
            break;
    }
    return vc;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)pressLogout:(id)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
}

@end

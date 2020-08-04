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
#import "TONavigationBar.h"

@interface ParentViewController ()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *controllerView;
@property (strong, nonatomic) HMSegmentedControl* segmentedControl;
@property (strong, nonatomic) NSMutableArray* vcArray;
@property (weak, nonatomic) IBOutlet UIButton *userButton;

@end

@implementation ParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([FBSDKAccessToken currentAccessToken] == nil) {
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Conversation", @"Translate", @"Scan"]];
        [self.userButton setTitle:@"Sign in" forState:UIControlStateNormal];
    } else {
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Conversation", @"Translate", @"Scan", @"Saved", @"Learn"]];
    }
    self.vcArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < 5; i++) {
        [self.vcArray addObject:[NSNull null]];
    }
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
    self.segmentedControl.titleTextAttributes = @{
    NSForegroundColorAttributeName : [UIColor lightGrayColor],
    NSFontAttributeName : [UIFont systemFontOfSize:16]};
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:33.0 / 255 green:150.0 / 255 blue:243.0 / 255 alpha:1]};
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    [self displayCurrentTab:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.navigationController.to_navigationBar setBackgroundHidden:NO animated:animated forViewController:self];
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
    [self addChildViewController:self.vcArray[index]];
    [vc didMoveToParentViewController:self];
    vc.view.frame = self.controllerView.bounds;
    [self.controllerView addSubview:vc.view];
    self.currentViewController = vc;
    
}

- (UIViewController *)viewControllerForSelectedSegementIndex:(NSUInteger )index {
    UIViewController *vc;
    switch (index) {
        case 0:
            if (self.vcArray[index] == [NSNull null]) {
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationController"];
                [self.vcArray insertObject:vc atIndex:index];
            } else {
                vc = self.vcArray[index];
            }
            break;
        case 1:
            if (self.vcArray[index] == [NSNull null]) {
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TranslateController"];
                [self.vcArray insertObject:vc atIndex:index];
            } else {
                vc = self.vcArray[index];
            }
            break;
        case 2:
            if (self.vcArray[index] == [NSNull null]) {
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanController"];
                [self.vcArray insertObject:vc atIndex:index];
            } else {
                vc = self.vcArray[index];
            }
            break;
        case 3:
            if (self.vcArray[index] == [NSNull null]) {
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SavedController"];
                [self.vcArray insertObject:vc atIndex:index];
            } else {
                vc = self.vcArray[index];
            }
            break;
        case 4:
            if (self.vcArray[index] == [NSNull null]) {
                vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LearnController"];
                [self.vcArray insertObject:vc atIndex:index];
            } else {
                vc = self.vcArray[index];
            }
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

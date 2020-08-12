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
#import "SKSplashIcon.h"
#import "TONavigationBar.h"

@interface ParentViewController ()
@property (strong, nonatomic) SKSplashView *splashView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *controllerView;
@property (strong, nonatomic) HMSegmentedControl* segmentedControl;
@property (strong, nonatomic) NSMutableArray* vcArray;
@property (assign, nonatomic) BOOL splashShow;

@end

@implementation ParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.vcArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < 5; i++) {
        [self.vcArray addObject:[NSNull null]];
    }
    self.title = @"Breaking Barriers";
    //self.navigationController.navigationBar.prefersLargeTitles = YES;

    self.view.backgroundColor = [UIColor whiteColor];
    if ([FBSDKAccessToken currentAccessToken] == nil) {
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Conversation", @"Translate", @"Scan"]];
    } else {
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Conversation", @"Translate", @"Scan", @"Saved", @"Learn"]];
    }
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
    self.segmentedControl.hidden = YES;
    [self splash];
}

-(void)splash {
    //Twitter style splash
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"icon_60pt"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = [UIColor colorWithRed:0 green:150.0 / 255 blue:1 alpha:1];
    self.splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon animationType:SKSplashAnimationTypeNone];
    self.splashView.delegate = self; //Optional -> if you want to receive updates on animation beginning/end
    self.splashView.backgroundColor = twitterColor;
    self.splashView.animationDuration = 2.5; //Optional -> set animation duration. Default: 1s
    [self.view addSubview:self.splashView];
    self.navigationController.navigationBar.hidden = YES;
    [self.splashView startAnimation];
}

- (void) splashViewDidEndAnimating:(SKSplashView *)splashView
{
    NSLog(@"Stopped animating from delegate");
    self.navigationController.navigationBar.hidden = NO;
    self.segmentedControl.hidden = NO;
    //To stop activity animation when splash animation ends
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

@end

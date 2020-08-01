//
//  LearnViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/23/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//
#import <Parse/Parse.h>
#import "DraggableViewBackground.h"
#import "LearningCell.h"
#import "LearnViewController.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "SavedText.h"
#import "SceneDelegate.h"

@interface LearnViewController ()
@property (strong, nonatomic) MBProgressHUD *hud;
@property DraggableViewBackground *draggableBackground;

@end

@implementation LearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.label.text = @"Loading";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
    [self.view addSubview:draggableBackground];
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

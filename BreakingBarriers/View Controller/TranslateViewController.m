//
//  TranslateViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/16/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "TranslateViewController.h"
@import MLKit;

@interface TranslateViewController ()
@property (weak, nonatomic) IBOutlet UIButton *langOneButton;
@property (weak, nonatomic) IBOutlet UIButton *langTwoButton;
@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;

@end

@implementation TranslateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

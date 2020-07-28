//
//  LearnViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/23/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//
#import <Parse/Parse.h>
#import "LearningCell.h"
#import "LearnViewController.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "SavedText.h"
#import "SceneDelegate.h"

@interface LearnViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *saved;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation LearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.label.text = @"Loading";
    [self querySaved];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self querySaved];
}

- (void)querySaved {
    PFQuery *query = [PFQuery queryWithClassName:@"SavedText"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects != nil) {
            self.saved = objects;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.collectionView reloadData];
            });
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.saved.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LearningCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LearnCell" forIndexPath:indexPath];
    SavedText *saved = self.saved[indexPath.item];
    [cell setCard:saved];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LearningCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell flipCard];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)logout:(id)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *) self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
}

@end

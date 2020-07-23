//
//  SavedViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/23/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import <Parse/Parse.h>
#import "SavedCell.h"
#import "SavedText.h"
#import "SavedViewController.h"

@interface SavedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *saved;

@end

@implementation SavedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.saved.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SavedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SavedCell" forIndexPath:indexPath];
    SavedText *saved = self.saved[indexPath.row];
    [cell setSaved:saved];
    return cell;
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

//
//  SavedViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/23/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "SavedCell.h"
#import "SavedText.h"
#import "SavedViewController.h"

@interface SavedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *saved;
@property (strong, nonatomic) NSMutableDictionary *savedDict;
@property (strong, nonatomic) NSArray *allKeys;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation SavedViewController

NSString *HeaderViewIdentifier = @"TableViewHeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.label.text = @"Loading";
    self.savedDict = [[NSMutableDictionary alloc]init];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderViewIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([PFUser currentUser] != nil) {
        [self querySaved];
    }
}

- (void)querySaved {
    NSLog(@"query");
    PFQuery *query = [PFQuery queryWithClassName:@"SavedText"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects != nil) {
            self.saved = objects;
            [self arrayToDictionary];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void)arrayToDictionary {
    [self.savedDict removeAllObjects];
    for (SavedText *saved in self.saved) {
        NSString *language = [NSLocale.currentLocale localizedStringForLanguageCode:saved.sourceLanguage];
        if ([self.savedDict objectForKey:language]) {
            [self.savedDict[language] addObject:saved];
        } else {
            NSMutableArray *savedArray = [[NSMutableArray alloc]init];
            [savedArray addObject:saved];
            [self.savedDict setObject:savedArray forKey:language];
        }
    }
    self.allKeys = [self.savedDict allKeys];
    NSLog(@"%@", self.savedDict);
    NSLog(@"%lu", (unsigned long)[self.savedDict[self.allKeys[0]] count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.savedDict count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.savedDict[self.allKeys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SavedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SavedCell" forIndexPath:indexPath];
    NSArray *savedLang = self.savedDict[self.allKeys[indexPath.section]];
    SavedText *saved = savedLang[indexPath.row];
    [cell setSaved:saved];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewIdentifier];
    header.textLabel.text = self.allKeys[section];
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont boldSystemFontOfSize:18];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
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

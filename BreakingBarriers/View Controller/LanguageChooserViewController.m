//
//  LanguageChooserViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/15/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "LanguageChooserViewController.h"
#import "LanguageCell.h"
@import MLKit;

@interface LanguageChooserViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray<MLKTranslateLanguage> *allLanguages;

@end

@implementation LanguageChooserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"lang 1: %d", self.langOne);
    NSLog(@"lang 2: %d", self.langTwo);
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSLocale *currentLocale = NSLocale.currentLocale;
    self.allLanguages = [MLKTranslateAllLanguages().allObjects
    sortedArrayUsingComparator:^NSComparisonResult(NSString *_Nonnull lang1,
                                                   NSString *_Nonnull lang2) {
      return [[currentLocale localizedStringForLanguageCode:lang1]
          compare:[currentLocale localizedStringForLanguageCode:lang2]];
    }];
}
- (IBAction)pressX:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LanguageCell" forIndexPath:indexPath];
    NSLog(@"%@", self.allLanguages[indexPath.row]);
    cell.languageLabel.text = [NSLocale.currentLocale localizedStringForLanguageCode:self.allLanguages[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allLanguages.count;
}

@end

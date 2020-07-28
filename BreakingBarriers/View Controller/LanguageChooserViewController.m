//
//  LanguageChooserViewController.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/15/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "LanguageChooserViewController.h"
#import "LanguageCell.h"

@interface LanguageChooserViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray<MLKTranslateLanguage> *allLanguages;
@property (nonatomic, strong) NSMutableArray<MLKTranslateLanguage> *filteredLanguages;
@property (nonatomic, assign) BOOL isFiltered;

@end

@implementation LanguageChooserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"lang 1: %d", self.langOne);
    NSLog(@"lang 2: %d", self.langTwo);
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    NSLocale *currentLocale = NSLocale.currentLocale;
    self.allLanguages = [MLKTranslateAllLanguages().allObjects
    sortedArrayUsingComparator:^NSComparisonResult(NSString *_Nonnull lang1,
                                                   NSString *_Nonnull lang2) {
      return [[currentLocale localizedStringForLanguageCode:lang1]
          compare:[currentLocale localizedStringForLanguageCode:lang2]];
    }];
    self.isFiltered = NO;
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
    if (self.isFiltered) {
        cell.languageLabel.text = [NSLocale.currentLocale localizedStringForLanguageCode:self.filteredLanguages[indexPath.row]];
        [cell setLangauge:self.filteredLanguages[indexPath.row]];
    } else {
        cell.languageLabel.text = [NSLocale.currentLocale localizedStringForLanguageCode:self.allLanguages[indexPath.row]];
        [cell setLangauge:self.allLanguages[indexPath.row]];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isFiltered) {
        return self.filteredLanguages.count;
    }
    return self.allLanguages.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isFiltered) {
        NSString *language = self.filteredLanguages[indexPath.row];
        NSLog(@"%@", language);
        [self.delegate languageChooserViewController:self didPickLanguage:language];
    } else {
        NSString *language = self.allLanguages[indexPath.row];
        NSLog(@"%@", language);
        [self.delegate languageChooserViewController:self didPickLanguage:language];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.isFiltered = NO;
        [self.searchBar endEditing:YES];
    } else {
        self.isFiltered = YES;
        self.filteredLanguages = [[NSMutableArray alloc] init];
        for (MLKTranslateLanguage language in self.allLanguages) {
            NSString *languageString = [NSLocale.currentLocale localizedStringForLanguageCode:language];
            NSRange range = [languageString rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [self.filteredLanguages addObject:language];
            }
        }
    }
    [self.tableView reloadData];
}

@end

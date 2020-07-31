//
//  LanguageCell.h
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/15/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

@import MLKit;
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LanguageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (strong, nonatomic) NSString *langCode;
@property (weak, nonatomic) NSProgress *progress;

- (void)setLangauge:(NSString *)langauge;

@end

NS_ASSUME_NONNULL_END

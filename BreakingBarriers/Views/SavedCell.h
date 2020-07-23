//
//  SavedCell.h
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/23/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//
@import Parse;
#import "SavedText.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SavedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sourceText;
@property (weak, nonatomic) IBOutlet UILabel *translatedText;
@property (weak, nonatomic) IBOutlet UIButton *savedButton;
@property (strong, nonatomic) SavedText *saved;

- (void)setSaved:(SavedText *)saved;


@end

NS_ASSUME_NONNULL_END

//
//  LearningCell.h
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/23/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedText.h"

NS_ASSUME_NONNULL_BEGIN

@interface LearningCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *frontView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *sourceText;
@property (weak, nonatomic) IBOutlet UILabel *targetText;
@property (weak, nonatomic) IBOutlet UILabel *targetLanguage;
@property (weak, nonatomic) IBOutlet UILabel *sourceLangauge;
@property (assign, nonatomic) BOOL frontHidden;

- (void)setCard:(SavedText *)saved;
- (void)flipCard;

@end

NS_ASSUME_NONNULL_END

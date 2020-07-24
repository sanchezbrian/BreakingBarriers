//
//  LearningCell.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/23/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "LearningCell.h"
#import "SavedText.h"

@implementation LearningCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frontHidden = YES;
}

- (void)setCard:(SavedText *)saved {
    self.sourceText.text = saved.sourceText;
    self.targetText.text = saved.translatedText;
}

- (void)flipCard {
    if (self.frontHidden) {
//        [self.frontView setHidden:NO];
//        [self.backView setHidden:YES];
        UIViewAnimationOptions transitionOption = UIViewAnimationOptionTransitionFlipFromLeft;
        [UIView transitionFromView:self.backView toView:self.frontView duration:0.5 options:(transitionOption | UIViewAnimationOptionShowHideTransitionViews) completion:^(BOOL finished) {
            NSLog(@"Success! for back to front");
            self.frontHidden = NO;
        }];
    } else {
//        [self.frontView setHidden:YES];
//        [self.backView setHidden:NO];
        UIViewAnimationOptions transitionOption = UIViewAnimationOptionTransitionFlipFromRight;
        [UIView transitionFromView:self.frontView toView:self.backView duration:0.5 options:(transitionOption | UIViewAnimationOptionShowHideTransitionViews) completion:^(BOOL finished) {
            NSLog(@"Success! for front to back");
            self.frontHidden = YES;
        }];
    }
}

@end

//
//  SavedCell.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/23/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "SavedCell.h"

@implementation SavedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSaved:(SavedText *)saved {
    self.sourceText.text = saved[@"sourceText"];
    self.translatedText.text = saved[@"translatedText"];
}

@end

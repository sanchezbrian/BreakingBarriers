//
//  SavedCell.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/23/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "SavedCell.h"
#import "SavedText.h"

@implementation SavedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.savedButton setSelected:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)tapSave:(id)sender {
    if (self.savedButton.isSelected) {
        PFQuery *query = [PFQuery queryWithClassName:@"SavedText"];
        [query whereKey:@"objectId" equalTo:self.saved.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            [PFObject deleteAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                NSLog(@"Sucessfully deleted!");
                [self.savedButton setSelected:NO];
            }];
        }];
    } else {
        [SavedText postSavedText:self.saved.sourceText withOutputText:self.saved.translatedText sourceLanguage:self.saved.sourceLanguage outputLanguage:self.saved.translatedLanguage withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"Sucessfully saved! %@", self.saved);
                [self.savedButton setSelected:YES];
            }
        }];
    }
}

- (void)setSaved:(SavedText *)saved {
    _saved = saved;
    self.sourceText.text = saved[@"sourceText"];
    self.translatedText.text = saved[@"translatedText"];
}

@end

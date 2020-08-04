//
//  LanguageCell.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/15/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "LanguageCell.h"
#import "MBProgressHUD.h"
#import "TONavigationBar.h"

@implementation LanguageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSSet<MLKTranslateRemoteModel *> *localModels = [MLKModelManager modelManager].downloadedTranslateModels;
    NSLog(@"%@", localModels);
    self.progressView.alpha = 0;
//    self.contentView.backgroundColor = UIColor.darkGrayColor;
    self.cellView.layer.cornerRadius = 12;
    [self.cellView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.cellView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.cellView.layer setShadowRadius:1.5];
    [self.cellView.layer setShadowOpacity:0.5];
    self.cellView.clipsToBounds = false;
    self.cellView.layer.masksToBounds = false;
    
}

- (BOOL)isLanguageDownloaded:(MLKTranslateLanguage)language {
    MLKTranslateRemoteModel *model = [self modelForLanguage:language];
    MLKModelManager *modelManager = [MLKModelManager modelManager];
    return [modelManager isModelDownloaded:model];
}

- (MLKTranslateRemoteModel *)modelForLanguage:(MLKTranslateLanguage)language {
  return [MLKTranslateRemoteModel translateRemoteModelWithLanguage:language];
}

- (void)setLangauge:(NSString *)langauge {
    self.langCode = langauge;
    if ([self isLanguageDownloaded:langauge]) {
        [self.downloadButton setSelected:YES];
    } else {
        [self.downloadButton setSelected:NO];
    }
}

- (IBAction)pressDownload:(id)sender {
    if ([self.downloadButton isSelected]) {
        MLKTranslateRemoteModel *model = [self modelForLanguage:self.langCode];
        [[MLKModelManager modelManager] deleteDownloadedModel:model completion:^(NSError * _Nullable error) {
             if (error != nil) {
                 return;
             }
            NSLog(@"Succesful Deletion");
            [UIView animateWithDuration:.2 animations:^{
                self.progressView.alpha = 0;
            }];
            [self.downloadButton setSelected:NO];
        }];
    } else {
        MLKModelDownloadConditions *conditions = [[MLKModelDownloadConditions alloc] initWithAllowsCellularAccess:NO allowsBackgroundDownloading:YES];
        MLKTranslateRemoteModel *model = [self modelForLanguage:self.langCode];
        [UIView animateWithDuration:.2 animations:^{
            self.progressView.alpha = 1;
        }];
        self.progressView.observedProgress = [[MLKModelManager modelManager] downloadModel:model conditions:conditions];
        [self updateProgress];
    }
}

- (void)updateProgress {
    if (self.progressView.progress < 1.0) {
        [self performSelector:@selector(updateProgress) withObject:nil afterDelay:0.2];
        [self setUserInteractionEnabled:NO];
    } else {
        [self.downloadButton setSelected:YES];
        [self setUserInteractionEnabled:YES];
        self.progressView.alpha = 0;
    }
}

@end

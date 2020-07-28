//
//  LanguageCell.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/15/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "LanguageCell.h"
#import "MBProgressHUD.h"

@implementation LanguageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSSet<MLKTranslateRemoteModel *> *localModels = [MLKModelManager modelManager].downloadedTranslateModels;
    NSLog(@"%@", localModels);
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
            [self.downloadButton setSelected:NO];
        }];
    } else {
        MLKModelDownloadConditions *conditions = [[MLKModelDownloadConditions alloc] initWithAllowsCellularAccess:NO allowsBackgroundDownloading:YES];
        MLKTranslateRemoteModel *model = [self modelForLanguage:self.langCode];
        [[MLKModelManager modelManager] downloadModel:model conditions:conditions];
        [self.downloadButton setSelected:YES];
    }
}

@end

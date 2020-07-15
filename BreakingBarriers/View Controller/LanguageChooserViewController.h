//
//  LanguageChooserViewController.h
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/15/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MLKit;
@class LanguageChooserViewController;

@protocol LanguageChooserViewControllerDelegate

- (void)languageChooserViewController:(LanguageChooserViewController *)contoller didPickLanguage:(NSString *)language;

@end

@interface LanguageChooserViewController : UIViewController

@property (weak, nonatomic) id<LanguageChooserViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL langOne;
@property (assign, nonatomic) BOOL langTwo;

@end


//
//  SavedText.h
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/22/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface SavedText : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *sourceText;
@property (nonatomic, strong) NSString *translatedText;
@property (nonatomic, strong) NSString *sourceLanguage;
@property (nonatomic, strong) NSString *translatedLanguage;

+ (void) postSavedText: (NSString *)sourceText withOutputText: (NSString *)outputText sourceLanguage: (NSString *)langId outputLanguage: (NSString *)langId2 withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END

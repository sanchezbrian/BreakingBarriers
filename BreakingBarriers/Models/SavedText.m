//
//  SavedText.m
//  BreakingBarriers
//
//  Created by Brian Sanchez on 7/22/20.
//  Copyright © 2020 Brian Sanchez. All rights reserved.
//

#import "SavedText.h"
#import <Parse/Parse.h>

@implementation SavedText

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic sourceText;
@dynamic translatedText;
@dynamic sourceLanguage;
@dynamic translatedLanguage;
 
+ (nonnull NSString *)parseClassName {
    return @"SavedText";
}

+ (void)postSavedText:(NSString *)sourceText withOutputText:(NSString *)outputText sourceLanguage:(NSString *)langId outputLanguage:(NSString *)langId2 withCompletion:(PFBooleanResultBlock)completion {
    SavedText *newSave = [SavedText new];
    newSave.sourceText = sourceText;
    newSave.translatedText = outputText;
    newSave.sourceLanguage = langId;
    newSave.translatedLanguage = langId2;
    newSave.author = [PFUser currentUser];
    [newSave saveInBackgroundWithBlock:completion];
}

@end

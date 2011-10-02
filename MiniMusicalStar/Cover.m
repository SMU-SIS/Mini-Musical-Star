//
//  Cover.m
//  MMS-UI
//
//  Created by Jun Kit Lee on 17/9/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Cover.h"


@implementation Cover
@dynamic author;
@dynamic cover_of_showID;
@dynamic created_date;
@dynamic title;
@dynamic Scenes;

- (BOOL)showWasEdited
{
    //iterate through all cover scenes
    __block BOOL hasEdits = NO;
    [self.Scenes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        CoverScene *coverScene = (CoverScene *)obj;
        if ([coverScene sceneHasEdits])
        {
            hasEdits = YES;
            *stop = YES;
        }
    }];
    
    return hasEdits;
}

- (void)purgeRelatedFiles
{
    NSLog(@"This method has to be implemented to delete all the user-created audio and photo files that are associated with this cover.");
}

@end

//
//  Cover.m
//  MMS-UI
//
//  Created by Jun Kit Lee on 17/9/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Cover.h"
#import "CoverScene.h"

@implementation Cover
@dynamic author;
@dynamic cover_of_showHash;
@dynamic originalHash;
@dynamic created_date;
@dynamic title;
@dynamic Scenes;

- (void)purgeRelatedFiles
{
    [self.Scenes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [obj performSelector:@selector(purgeRelatedFiles)];
    }];
}

- (CoverScene *)coverSceneForSceneHash:(NSString *)sceneHash
{
    __block CoverScene *returnScene = nil;
    [self.Scenes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        CoverScene *theScene = (CoverScene *)obj;
        NSLog(@"theScene.sceneHash is %@ and sceneHash is %@", theScene.sceneHash, sceneHash);
        if ([theScene.sceneHash isEqualToString:sceneHash])
        {
            returnScene = theScene;
            
            *stop = YES;
        }
    }];
    
    return returnScene;
}

@end

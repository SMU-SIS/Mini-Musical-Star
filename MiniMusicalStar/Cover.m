//
//  Cover.m
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 27/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Cover.h"
#import "CoverScene.h"


@implementation Cover

@dynamic author;
@dynamic coverOfShowHash;
@dynamic created_date;
@dynamic originalHash;
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

//
//  CoverScene.m
//  MMS-UI
//
//  Created by Jun Kit Lee on 17/9/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "CoverScene.h"
#import "Cover.h"
#import "CoverSceneAudio.h"
#import "CoverScenePicture.h"


@implementation CoverScene
@dynamic SceneNum;
@dynamic Audio;
@dynamic Cover;
@dynamic Picture;

- (CoverScenePicture *)pictureForOrderNumber:(int)orderNum
{
    __block CoverScenePicture *pictureToReturn = nil;
    
    [self.Picture enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        CoverScenePicture *theCoverPicture = (CoverScenePicture *)obj;
        if ([theCoverPicture.OrderNumber intValue] == (orderNum))
        {
            pictureToReturn = theCoverPicture;
            *stop = YES;
        }
    }];
    
    return pictureToReturn;
}

- (CoverSceneAudio *)audioForTrackTitle:(NSString *)trackTitle
{
    __block CoverSceneAudio *audioToReturn = nil;
    
    [self.Audio enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        CoverSceneAudio *theCoverAudio = (CoverSceneAudio *)obj;
        if ([theCoverAudio.title isEqualToString:trackTitle])
        {
            audioToReturn = theCoverAudio;
            *stop = YES;
        }
    }];
    
    return audioToReturn;
}

@end

//
//  CoverScene.m
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 9/10/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "CoverScene.h"
#import "Cover.h"
#import "CoverSceneAudio.h"
#import "CoverScenePicture.h"


@implementation CoverScene
@dynamic sceneHash;
@dynamic Audio;
@dynamic Cover;
@dynamic Picture;

- (NSArray *)sortedAudio
{
    //later date first
    NSArray *sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO], nil];
    return [self.Audio sortedArrayUsingDescriptors:sortDescriptors];
}

- (CoverScenePicture *)pictureForOriginalHash:(NSString *)hash
{
    __block CoverScenePicture *pictureToReturn = nil;
    
    [self.Picture enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        CoverScenePicture *theCoverPicture = (CoverScenePicture *)obj;
        if ([theCoverPicture.originalHash isEqualToString:hash])
        {
            pictureToReturn = theCoverPicture;
            *stop = YES;
        }
    }];
    
    return pictureToReturn; 
}

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

- (BOOL)sceneHasEdits
{
    return !((self.Audio.count == 0) && (self.Picture.count == 0));
}

- (void)purgeRelatedFiles
{
    [self.Audio enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [obj performSelector:@selector(deleteAudioFile)];
    }];
    
    [self.Picture enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [obj performSelector:@selector(deletePictureFile)];
    }];
}

@end

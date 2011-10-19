//
//  SceneUtility.m
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 17/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SceneUtility.h"
#import "Scene.h"
#import "CoverScene.h"
#import "Audio.h"
#import "CoverSceneAudio.h"
#import "Picture.h"
#import "CoverScenePicture.h"

@implementation SceneUtility

@synthesize theScene;
@synthesize theCoverScene;
@synthesize arrayOfAllTracks;
//@synthesize thePlayer;

- (void)dealloc
{
    [theScene release];
    [theCoverScene release];
    [super dealloc];
}

- (SceneUtility*) initWithSceneAndCoverScene:(Scene*)scene :(CoverScene*)coverScene {
    theScene = scene;
    theCoverScene = coverScene;
//    thePlayer = aPlayer;
    
    return self;
}

- (NSMutableArray*) getMergedImagesArray
{
    
    int seconds = 0;
    int processedImages = 0;
    int numberOfImages = [theScene.pictureDict count];
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    
    while (processedImages < numberOfImages)
    {
        Picture *thePicture = [theScene pictureForAbsoluteSecond:seconds];
        if (thePicture)
        {
            //check if there is a cover picture
            CoverScenePicture *coverPicture = [theCoverScene pictureForOriginalHash:thePicture.hash];
            
            if (coverPicture)
            {
                [imagesArray addObject:[coverPicture image]];
            }
            
            else
            {
                [imagesArray addObject:thePicture.image];
                
            }
            
            processedImages++;
        }
        
        seconds++;
    }
    return imagesArray;
}

- (void)consolidateOriginalAndCoverTracks
{  
    self.arrayOfAllTracks = [NSMutableArray arrayWithCapacity:theScene.audioTracks.count + theCoverScene.Audio.count];
    
    [theScene.audioTracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.arrayOfAllTracks addObject:obj];
    }];
    
    [theCoverScene.Audio enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.arrayOfAllTracks addObject:obj];
    }];
}

- (NSArray*)getExportAudioURLs
{
    NSMutableArray *mutableArrayOfAudioURLs = [NSMutableArray arrayWithCapacity:1]; //don't know how big it will be, just start with 1 
    
    [arrayOfAllTracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {        
        if ([obj isKindOfClass:[Audio class]])
        {
            Audio *anAudio = (Audio*)obj;
            NSURL *audioURL = [NSURL fileURLWithPath:anAudio.path];
            
            //add only if the audio is not muted
//            if ([thePlayer busNumberIsMuted:idx] == NO)
//            {
                [mutableArrayOfAudioURLs addObject:audioURL];
                
//            }
            
        } else if ([obj isKindOfClass:[CoverSceneAudio class]])
        {
            CoverSceneAudio *anCoverSceneAudio = (CoverSceneAudio*)obj;
            NSURL *audioURL = [NSURL fileURLWithPath:anCoverSceneAudio.path];
            
            //add only if the audio is not muted
//            if ([thePlayer busNumberIsMuted:idx] == NO)
//            {
                [mutableArrayOfAudioURLs addObject:audioURL];
                
//            }
        }
        
    }];
    
    NSArray *arrayOfAudioURLs = [[[NSArray alloc] initWithArray:mutableArrayOfAudioURLs] autorelease];
    
    return arrayOfAudioURLs;
}


@end

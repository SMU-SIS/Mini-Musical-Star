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

- (void)dealloc
{
    [theScene release];
    [theCoverScene release];
    [super dealloc];
}

- (SceneUtility*) initWithSceneAndCoverScene:(Scene*)scene :(CoverScene*)coverScene {
    theScene = scene;
    theCoverScene = coverScene;
    
    //[self consolidateOriginalAndCoverTracks];
    
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
    
    [theScene.audioTracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { 
        Audio *anAudio = (Audio*)obj;
        NSURL *audioURL = nil;
        
        CoverSceneAudio *theCoverSceneAudio = [self hasCoverAudio:anAudio];
        if (theCoverSceneAudio != nil) {
            //if there is a cover scene audio
            audioURL = [NSURL fileURLWithPath:theCoverSceneAudio.path];
        } else {
            //if there is no coverscene audio
            audioURL = [NSURL fileURLWithPath:anAudio.path];
        }
        
        [mutableArrayOfAudioURLs addObject:audioURL];

    }];
    
    NSArray *arrayOfAudioURLs = [[[NSArray alloc] initWithArray:mutableArrayOfAudioURLs] autorelease];
    
    return arrayOfAudioURLs;
}

- (CoverSceneAudio*)hasCoverAudio:(Audio*)anAudio
{
    __block CoverSceneAudio *aCoverSceneAudio = nil;
    
    [theCoverScene.Audio enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {   
        aCoverSceneAudio = (CoverSceneAudio*)obj;
        
        if ([anAudio.hash isEqualToString:aCoverSceneAudio.OriginalHash]) {
            *stop = YES;
            NSLog(@"a cover scene exist for %@", anAudio.title);
        }
    }];
     
     return aCoverSceneAudio;
}

@end

//
//  SceneUtility.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 17/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MixPlayerRecorder.h"
@class Scene;
@class CoverScene;
@class Audio;
@class CoverSceneAudio;
@class Picture;

@interface SceneUtility : NSObject
{
    NSMutableArray *arrayOfAllTracks;
//    MixPlayerRecorder *thePlayer;
}

@property (retain,nonatomic) Scene *theScene;
@property (retain,nonatomic) CoverScene *theCoverScene;

@property (retain,nonatomic) NSMutableArray *arrayOfAllTracks;
//@property (retain,nonatomic) MixPlayerRecorder *thePlayer;

- (NSMutableArray*) getMergedImagesArray;
- (NSArray*)getExportAudioURLs;
- (SceneUtility*) initWithSceneAndCoverScene:(Scene*)scene :(CoverScene*)coverScene;
- (void)consolidateOriginalAndCoverTracks;

@end

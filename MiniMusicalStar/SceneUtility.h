//
//  SceneUtility.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 17/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Scene;
@class CoverScene;
@class Audio;
@class CoverSceneAudio;

@interface SceneUtility : NSObject

@property (retain,nonatomic) Scene *theScene;
@property (retain,nonatomic) CoverScene *theCoverScene;

-(void) initWithSceneAndCoverScene:(Scene*)scene :(CoverScene*)coverScene;

@end

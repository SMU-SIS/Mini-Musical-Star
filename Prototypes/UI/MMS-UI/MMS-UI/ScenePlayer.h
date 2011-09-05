//
//  ShowAndScenePlayer.h
//  MMS-UI
//
//  Created by Jun Kit Lee on 5/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"
#import "Audio.h"
#import "MixPlayerRecorder.h"

@interface ScenePlayer : NSObject {
    MixPlayerRecorder *audioPlayer;
}

@property (retain, nonatomic) Scene *theScene;
@property (retain, nonatomic) UIView *theView;
@property (retain, nonatomic) MixPlayerRecorder *audioPlayer;

- (id)initWithScene: (Scene *)aScene andView: (UIView *)aView;
- (void)startPlayback;
- (void)performUpdateOfImageInView;
@end

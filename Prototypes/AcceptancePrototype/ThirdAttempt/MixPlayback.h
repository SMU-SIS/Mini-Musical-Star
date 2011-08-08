//
//  MixPlayback.h
//  ThirdAttempt
//
//  Created by Jun Kit on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface MixPlayback : NSObject {
    AVMutableComposition *composition;
    AVPlayer *player;
    BOOL enableNotifications; //array of CMTime to notify caller
    id observerObject;
}

@property (nonatomic, retain) AVMutableComposition *composition;
@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic) BOOL enableNotifications;

- (MixPlayback *)initMixWithAudioFiles:(NSArray *)audioFileURLs;
- (void)play;
- (void)pause;
- (void)dealloc;
@end

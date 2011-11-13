//
//  CueController.h
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Cue;
@interface CueController : NSObject
{
    int currentSecond;
}

@property (retain, nonatomic) NSArray *tracks;
@property (assign, nonatomic) Cue *currentCue;
@property (assign, nonatomic) id delegate;

- (id)initWithAudioArray:(NSArray *)tracksArray;
- (Cue *)getCurrentCueForTrackIndex: (int)trackIndex;
- (void)deregisterNotifications;
@end

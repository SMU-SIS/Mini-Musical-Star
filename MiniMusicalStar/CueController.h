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

@property (retain, nonatomic) UIView *view;
@property (retain, nonatomic) NSArray *tracks;
@property (retain, nonatomic) Cue *currentCue;
@property (assign, nonatomic) id delegate;

- (id)initWithAudioArray:(NSArray *)tracksArray;
- (Cue *)getCurrentCueForTrackIndex: (int)trackIndex;
- (void)loadView;
@end

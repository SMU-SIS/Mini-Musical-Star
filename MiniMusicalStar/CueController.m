//
//  CueController.m
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CueController.h"
#import "Cue.h"
#import "MixPlayerRecorder.h"
#import "Audio.h"

@implementation CueController
@synthesize tracks, currentCue, delegate;

- (void)dealloc
{
    NSLog(@"cuecontroller deallocating");
    
    [tracks release];
    [super dealloc];
}

- (id)initWithAudioArray:(NSArray *)tracksArray
{
    self = [super init];
    if (self)
    {
        self.tracks = tracksArray;
        
        //register to receive time elapsed notifcations
        NSLog(@"cuecontroller allocating");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveElapsedTimeNotification:) name:kMixPlayerRecorderPlaybackElapsedTimeAdvanced object:nil];
        
    }
    
    return self;
}

- (void)deregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
}

- (void)didReceiveElapsedTimeNotification:(NSNotification *)notification
{
    MixPlayerRecorder *thePlayer = notification.object;
    currentSecond = thePlayer.elapsedPlaybackTimeInSeconds;
    
    //check the current cue first to see if its time is up
    if (![self.currentCue shouldCueBeShowingAtSecond:currentSecond])
    {
        [delegate performSelectorOnMainThread:@selector(removeAndUnloadCueFromView) withObject:nil waitUntilDone:NO];
    }
    
    //check the tracks to see which ones got cues at this point in time and let the parent controller know
    [self.tracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[Audio class]])
        {
            Audio *anAudio = (Audio *)obj;
            Cue *aCue = [anAudio cueForSecond: currentSecond];
            
            if (aCue)
            {
                //notifiy the delegate to display a button on the corresponding track
                [[delegate dd_invokeOnMainThread] setCueButton:YES forTrackIndex:idx];
            }
            
            else
            {
                [[delegate dd_invokeOnMainThread] setCueButton:NO forTrackIndex:idx];
            }
        }
    }];
}

- (Cue *)getCurrentCueForTrackIndex: (int)trackIndex
{
    Audio *theAudio = (Audio *)[self.tracks objectAtIndex:trackIndex];
    return [theAudio cueForSecond:currentSecond];
}

@end

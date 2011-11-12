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
@synthesize view, tracks, currentCue, delegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [view release];
    [tracks release];
    [currentCue release];
    [super dealloc];
}

- (id)initWithAudioArray:(NSArray *)tracksArray
{
    self = [super init];
    if (self)
    {
        self.tracks = tracksArray;
        
        //register to receive time elapsed notifcations
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveElapsedTimeNotification:) name:kMixPlayerRecorderPlaybackElapsedTimeAdvanced object:nil];
        
    }
    
    return self;
}

- (void)didReceiveElapsedTimeNotification:(NSNotification *)notification
{
    MixPlayerRecorder *thePlayer = notification.object;
    currentSecond = thePlayer.elapsedPlaybackTimeInSeconds;
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

- (void)loadView
{
    /* constants related to displaying lyrics */
    #define LYRICS_VIEW_WIDTH 460 //the entire width of the landscape screen
    #define LYRICS_VIEW_HEIGHT 530
    #define LYRICS_VIEW_X 520
    #define LYRICS_VIEW_Y 30
    CGRect frame = CGRectMake(520, 30, 460, 100);
    self.view = [[UIView alloc] initWithFrame:frame];
    
    //create the content view
    UITextView *contentView = [[UITextView alloc] initWithFrame:frame];
    //contentView.text = self.theCue.content;
    contentView.backgroundColor = [UIColor redColor];
    [self.view addSubview:contentView];
}

@end
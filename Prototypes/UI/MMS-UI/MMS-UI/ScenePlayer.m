//
//  ShowAndScenePlayer.m
//  MMS-UI
//
//  Created by Jun Kit Lee on 5/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "ScenePlayer.h"

@implementation ScenePlayer
@synthesize theScene, theView, audioPlayer;

- (void)dealloc
{
    [audioPlayer stop];
    [audioPlayer release];
    [theScene release];
    [theView release];
    [super dealloc];
}

- (id)initWithScene: (Scene *)aScene andView: (UIView *)aView
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.theScene = aScene;
        self.theView = aView;
        
        NSMutableArray *audioPathURLs = [[NSMutableArray alloc] initWithCapacity:theScene.audioList.count];
        //get the audio paths out of the audioList
        [theScene.audioList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Audio *theAudio = (Audio *)obj;
            [audioPathURLs addObject:[NSURL fileURLWithPath:theAudio.path]];
        }];
        
        self.audioPlayer = [[MixPlayerRecorder alloc] initWithAudioFileURLs:audioPathURLs];
        [audioPathURLs release];
        
        //register to receive notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStartedNotification:) name:kMixPlayerRecorderPlaybackStarted object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStoppedNotification:) name:kMixPlayerRecorderPlaybackStopped object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveElapsedTimeNotification:) name:kMixPlayerRecorderPlaybackElapsedTimeAdvanced object:nil];
    }
    
    return self;
}

- (UIImage *)imageForCurrentTimeInSeconds:(int)currentSecond
{
    NSArray *picturesArray = theScene.pictureList;
    __block UIImage *imageToReturn;
    
    [picturesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Picture *thePicture = (Picture *)obj;
        
        if (thePicture.startTime <= [NSNumber numberWithInt:currentSecond])
        {
            int lala = [thePicture.startTime intValue];
            int baba = [thePicture.duration intValue];
            
            int mama = lala + baba;
            
            if (thePicture.startTime == [NSNumber numberWithInt:currentSecond])
            {
                imageToReturn = [thePicture.image retain];
                *stop = YES;
            }
            
            else if (mama >= currentSecond)
            {
                imageToReturn = [thePicture.image retain];
                *stop = YES;
            }
        }
    }];
    
    if (imageToReturn == nil)
    {
        imageToReturn = [UIImage imageNamed:@"g1.png"];
    }
    
    return imageToReturn;
                        
}

- (void)startPlayback
{
    [audioPlayer play];
}

- (void)didReceivePlayerStartedNotification:(NSNotification *)notification
{
    NSLog(@"received player start notification in ScenePlayer");
}

- (void)didReceivePlayerStoppedNotification:(NSNotification *)notification
{
    NSLog(@"received player stopped notification in ScenePlayer");
}

- (void)didReceiveElapsedTimeNotification:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(performUpdateOfImageInView) withObject:nil waitUntilDone:YES];
}

- (void)performUpdateOfImageInView
{
    [theView addSubview:[[UIImageView alloc] initWithImage:[self imageForCurrentTimeInSeconds:audioPlayer.elapsedPlaybackTimeInSeconds]]];
    
    //clear the previous view, if any
    if (theView.subviews.count > 1)
    {
        UIView *oldView = [theView.subviews objectAtIndex:0];
        [oldView removeFromSuperview];
        [oldView release];
    }

}
@end

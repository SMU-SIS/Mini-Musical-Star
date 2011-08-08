//
//  MixPlayback.m
//  ThirdAttempt
//
//  Created by Jun Kit on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MixPlayback.h"

@implementation MixPlayback
@synthesize composition, player, enableNotifications;

- (MixPlayback *)initMixWithAudioFiles:(NSArray *)audioFileURLs
{
    self = [super init];
    if (self) {
        // Create an array of AVURLAssets
        NSMutableArray *AVURLAssets = [NSMutableArray arrayWithCapacity:audioFileURLs.count];
        [audioFileURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:(NSURL *)obj options:nil];
            [AVURLAssets addObject:audioAsset];}];
        
        //create the AVMutableComposition
        composition = [[AVMutableComposition composition] retain];
        
        //do a foreach for every AVURLAsset and create tracks for them and add them to the composition
        [AVURLAssets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            AVURLAsset *object = (AVURLAsset *)obj;
            
            AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            AVAssetTrack *sourceAudioTrack = [[object tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            
            BOOL ok = NO;
            NSError *error = nil;
            
            CMTimeRange durationTimeRange = CMTimeRangeMake(kCMTimeZero, object.duration);
            
            ok = [audioTrack insertTimeRange:durationTimeRange ofTrack:sourceAudioTrack atTime:kCMTimeZero error:&error];
            if (!ok)
            {
                NSLog(@"%@", error);
            }
            NSLog(@"yoyo");
        }];
        
        enableNotifications = YES;
        player = [[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:composition]] retain];
        [player play];
        NSLog(@"the composition object:%@", composition);
        NSLog(@"the current item of the player is %@", player.currentItem);
        NSLog(@"the status of the player is %@", player.status);
    }
    
    return self;
}

- (void)play
{
    if (enableNotifications)
        observerObject = [[player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(2.0, 600) queue:nil usingBlock:^(CMTime time) {
                //[self performSelectorOnMainThread:@selector(test:) withObject:nil waitUntilDone:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeImage" object:nil];
        }] retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
    
    [player play];
}

-(void)test:(CMTime)time
{
    NSLog(@"Hello!\n");
}

- (void)pause
{
    [player pause];
}

- (void) playerItemDidReachEnd:(NSNotification *)notification
{
    NSLog(@"AVPlayer reached the end.");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player currentItem]];
    
    [player removeTimeObserver:observerObject];
    [observerObject release];
    
}

- (void)dealloc
{
    [player release];
    [composition release];
    [super dealloc];
}

@end

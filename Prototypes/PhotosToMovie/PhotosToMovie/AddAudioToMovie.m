//
//  AddAudioToMovie.m
//  PhotosToMovie
//
//  Created by Jun Kit on 28/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddAudioToMovie.h"


@implementation AddAudioToMovie

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (AVAsset *)addAudioToMovie:(NSString *)moviePath
{
    //let's get an AVAsset representation of the Friday mp3
    NSURL *audioURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Friday" ofType:@"mp3"]];
    AVAsset *audioAsset = [AVURLAsset URLAssetWithURL:audioURL options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey]];
    
    if (![audioAsset isPlayable])
        NSLog(@"Oops! AVFoundation reports that the audio asset is not playable. How ah?");
    
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    
    //now let's get an AVAsset representation of the movie
    NSURL *videoURL = [NSURL fileURLWithPath:moviePath];
    AVAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey]];
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    if (![videoAsset isPlayable])
        NSLog(@"Oops! AVFoundation reports that the video asset is not playable. How ah?");
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError *error = nil;
    BOOL ok = NO;
    
    ok = [compVideoTrack insertTimeRange:videoAssetTrack.timeRange ofTrack:videoAssetTrack atTime:CMTimeMake(1,600) error:&error];
    if (!ok)
        NSLog(@"Oops, an error occured. %@", [error localizedDescription]);
    
    ok = [compAudioTrack insertTimeRange:videoAssetTrack.timeRange ofTrack:audioAssetTrack atTime:CMTimeMake(1,600) error:&error];
    if (!ok)
        NSLog(@"Oops, an error occured. %@", [error localizedDescription]);
    
    
    return composition;
    
    
}

@end

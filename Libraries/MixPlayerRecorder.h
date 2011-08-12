//
//  MixPlayerRecorder.h
//  SimpleAudioRenderTest
//
//  Created by Jun Kit Lee on 11/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

//this class will post notifications when events occur. Register with NSNotificationCenter to receive them.
#define kMixPlayerRecorderPlaybackStarted @"kMixPlayerRecorderPlaybackStarted"
#define kMixPlayerRecorderPlaybackStopped @"kMixPlayerRecorderPlaybackStopped"
#define kMixPlayerRecorderPlaybackElapsedTimeAdvanced @"kMixPlayerRecorderPlaybackElapsedTimeAdvanced"

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "ASBDHelper.h"
#import "CAErrorHandling.h"
#import "AudioFileRingBuffer.h"

@interface MixPlayerRecorder : NSObject {
    NSMutableArray *audioRingBuffers;
    int numInputFiles;
    
    //AUGraph objects
    OSStatus error;
    AUGraph processingGraph;
    AudioUnit rioUnit;
    AudioUnit mixerUnit;
    AudioStreamBasicDescription asbdOutputFormat;
    
    //playback state flags
    UInt32 frameNum; //current playback position of the mix in frames
    UInt32 totalNumFrames; //total length in frames of the mix
    bool stoppedBecauseReachedEnd;
    
    //to send elasped time notifications
    UInt32 totalPlaybackTimeInSeconds;
    UInt32 elapsedPlaybackTimeInSeconds;
    bool isPlaying;
    
}

@property (nonatomic, readonly) int numInputFiles;
@property (nonatomic, readonly) bool isPlaying;
@property (nonatomic) bool stoppedBecauseReachedEnd;
@property (nonatomic) UInt32 frameNum;
@property (nonatomic, readonly) UInt32 totalNumFrames;
@property (nonatomic, readonly) UInt32 totalPlaybackTimeInSeconds; //read this to find out the total length of the mix
@property (nonatomic, readonly) UInt32 elapsedPlaybackTimeInSeconds; //read this when you are notified with kMixPlayerRecorderPlaybackElapsedTimeAdvanced to find out the new elapsed time (usually in periods of 1 second each)

-(MixPlayerRecorder *)initWithAudioFileURLs: (NSArray *)urls;
-(void)play;
-(void)stop;
-(void)seekTo:(UInt32)targetSeconds;
-(void)setVolume:(AudioUnitParameterValue)vol forBus:(UInt32)busNumber;
-(float)getVolumeForBus:(UInt32)busNumber;
-(void)enableRecordingToFile: (NSURL *)filePath;
-(void)setMicVolume: (float)vol;
-(void)disableRecording;

-(void)postNotificationForElapsedTime; //you don't have to call this manually


@end

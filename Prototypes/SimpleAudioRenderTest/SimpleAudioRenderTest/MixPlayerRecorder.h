//
//  MixPlayerRecorder.h
//  SimpleAudioRenderTest
//
//  Created by Jun Kit Lee on 11/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

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
}

-(MixPlayerRecorder *)initWithAudioFileURLs: (NSArray *)urls;
-(void)play;
-(void)stop;
-(void)seekTo: (CMTime)time;
-(void)setVolume: (float)vol forBus: (int)busNumber;
-(void)enableRecordingToFile: (NSURL *)filePath;
-(void)setMicVolume: (float)vol;
-(void)disableRecording;


@end

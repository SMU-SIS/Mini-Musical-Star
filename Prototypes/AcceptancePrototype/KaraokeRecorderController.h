//
//  KaraokeRecorderController.h
//  ThirdAttempt
//
//  Created by Jun Kit on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define MAXBUFS 2

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "CAErrorHandling.h"
#import "ASBDHelper.h"
#import "BoomzAUOutputCapturer.h"

typedef struct {
    AudioStreamBasicDescription asbd;
    AudioSampleType *data;
	UInt32 numFrames;
    UInt32 currentFrame;
} SoundBuffer, *SoundBufferPtr;

//this struct will contain the buffers to hold the converted-to-pcm audio file while waiting to feed into the mixer
typedef struct {
	UInt32 frameNum;
    UInt32 maxNumFrames;
    SoundBuffer* soundBuffer;
} SourceAudioBufferData, *SourceAudioBufferDataPtr;

@interface KaraokeRecorderController : NSObject {
    OSStatus error;
    AUGraph processingGraph;
    
    //the ASBD that we're going to feed into our mixer input bus 1 (for audio file)
    AudioStreamBasicDescription mClientFormat;
    AudioStreamBasicDescription mOutputFormat;
    
    SourceAudioBufferData mUserData;
    int numInputFiles;
    
    AudioUnit rioUnit;
    AudioUnit mixerUnit;
    
    BoomzAUOutputCapturer* rioCapturer;
    
    BOOL recordingEnabled;
}

-(KaraokeRecorderController*)initWithAudioFiles:(NSArray *)audioFileURLs;
-(void)startRecording;
-(void)stopRecording;
-(void)changeInputVolumeForBus:(UInt32)inputNum value:(AudioUnitParameterValue)value;
-(void)enableRecordingWithPath:(CFURLRef)outputFileURL forBus:(int)busNumber;

@end
//
//  KaraokeRecorderController.h
//  ThirdAttempt
//
//  Created by Jun Kit on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define MAXBUFS 1

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "CAErrorHandling.h"
#import "ASBDHelper.h"
#import "BoomzAUOutputCapturer.h"

typedef struct {
    AudioStreamBasicDescription asbd;
    AudioSampleType *data;
	UInt32 numFrames;
} SoundBuffer, *SoundBufferPtr;

//this struct will contain the buffers to hold the converted-to-pcm audio file while waiting to feed into the mixer
typedef struct {
	UInt32 frameNum;
    UInt32 maxNumFrames;
    SoundBuffer soundBuffer[MAXBUFS];
} SourceAudioBufferData, *SourceAudioBufferDataPtr;

@interface KaraokeRecorderController : NSObject {
    OSStatus error;
    AUGraph processingGraph;
    
    //the ASBD that we're going to feed into our mixer input bus 1 (for audio file)
    AudioStreamBasicDescription mClientFormat;
    AudioStreamBasicDescription mOutputFormat;
    
    SourceAudioBufferData mUserData;
    
    AudioUnit rioUnit;
    AudioUnit mixerUnit;
    
    BoomzAUOutputCapturer* rioCapturer;
    
    BOOL recordingEnabled;
    
    int maxBuffers; //how many audio file callbacks do we have?
    NSMutableArray *assetReaderOutputs;
}

@property (nonatomic, retain) NSMutableArray *assetReaderOutputs;
@property (nonatomic) SourceAudioBufferData mUserData;

-(KaraokeRecorderController*)initWithAudioFileArray:(NSArray *)audioFileArray;
-(void)startRecording;
-(void)stopRecording;
-(void)changeInputVolumeForBus:(UInt32)inputNum value:(AudioUnitParameterValue)value;
-(void)enableRecordingWithPath:(CFURLRef)outputFileURL forBus:(int)busNumber;

@end

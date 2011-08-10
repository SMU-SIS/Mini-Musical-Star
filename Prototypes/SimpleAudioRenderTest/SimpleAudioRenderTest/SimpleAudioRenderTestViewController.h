//
//  SimpleAudioRenderTestViewController.h
//  SimpleAudioRenderTest
//
//  Created by Jun Kit on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#define kBufferLength 4096

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "ASBDHelper.h"
#import "CAErrorHandling.h"
#import "TPCircularBuffer.h"

@interface SimpleAudioRenderTestViewController : UIViewController {
    OSStatus error;
    
    //the following ivars store information about the currently loaded audio file
    ExtAudioFileRef xafref;
    AudioStreamBasicDescription mClientFormat;
    long numFrames; //this numFrames is how many frames total in the audio file 
    long currentFrameNum;
    AudioStreamBasicDescription asbd;
    AudioSampleType *data; //a pointer to the actual buffer that is found at bufList.mBuffers[0].mData
    AudioBufferList bufList;
    
    
    //using the TPCircularBuffer instead
    SInt16 *buffer;
    TPCircularBufferRecord bufferRecord;
    NSLock *bufferRecordLock;
}
- (void)setupAudioFileUsingEAFS;
- (void)loadAudioFileUsingEAFS;
- (void)setupRemoteIOAudioUnit;
@end

//
//  SimpleAudioRenderTestViewController.m
//  SimpleAudioRenderTest
//
//  Created by Jun Kit on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kOutputBus 0
#define kInputBus 1
#define sineFrequency 880.0

#import "SimpleAudioRenderTestViewController.h"

@implementation SimpleAudioRenderTestViewController
@synthesize assetReaderOutput, startingFrameCount;
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set up the buffers with 4 seconds of interleaved stereo data
    bufferSize = 44100 * 2 * 4; //44100 is the sample rate per channel, 2 channel, 4 seconds
    [tempBuffer 
    
    
    
    [self loadAudioFile];
    [self setupRemoteIOAudioUnit];
}


static OSStatus playbackCallback(void *inRefCon, 
                                 AudioUnitRenderActionFlags *ioActionFlags, 
                                 const AudioTimeStamp *inTimeStamp, 
                                 UInt32 inBusNumber, 
                                 UInt32 inNumberFrames, 
                                 AudioBufferList *ioData) {    
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    
    SimpleAudioRenderTestViewController *this = (SimpleAudioRenderTestViewController *) inRefCon;
    
    CMSampleBufferRef ref = [this.assetReaderOutput copyNextSampleBuffer];
    CMItemCount numSamplesInBuffer = CMSampleBufferGetNumSamples(ref);
    printf("numsamplesinbuffer gives me %ld\n", numSamplesInBuffer);
    printf("innumberframes gives me %lu", inNumberFrames);
    AudioBufferList audioBufferList;
    CMBlockBufferRef blockBuffer;
    
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
                                                            ref,
                                                            NULL,
                                                            &audioBufferList,
                                                            sizeof(audioBufferList),
                                                            NULL,
                                                            NULL,
                                                            kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
                                                            &blockBuffer);
    
    for (int bufferCount = 0; bufferCount < audioBufferList.mNumberBuffers; bufferCount++)
    {
        SInt16 *samples = (SInt16 *)audioBufferList.mBuffers[bufferCount].mData;
        for (int i = 0; i < inNumberFrames; i++)
        {
            SInt16 *data = ioData->mBuffers[bufferCount].mData;
            (data)[i] = samples[i];
        }
        
    }
     
    
    
    /*
    double j = this.startingFrameCount;
    double cycleLength = 44100.0 / sineFrequency;
    
    for (int frame = 0; frame < inNumberFrames; frame++)
    {
        SInt16 *data = (SInt16 *)ioData->mBuffers[0].mData;
        (data)[frame] = (SInt16)sin (2 * M_PI * (j / cycleLength));
        printf("data is %i", (SInt16)sin (2 * M_PI * (j / cycleLength)));
        
        j += 1.0;
        if (j > cycleLength)
            j -= cycleLength;
        
    }
    
    this->startingFrameCount = j;
     */
    
    return noErr;
}

- (void)loadAudioFile
{
    NSString *audioURLString = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"m4a"];
    NSURL *audioURL = [NSURL fileURLWithPath:audioURLString];
    
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
    
    NSError *assetError = nil;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:audioAsset error:&assetError];
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                   [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:32], AVLinearPCMBitDepthKey,
                                   [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                   [NSNumber numberWithBool:YES], AVLinearPCMIsFloatKey,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                   [NSData data], AVChannelLayoutKey, nil];
    
    
    
    assetReaderOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioAsset.tracks audioSettings:audioSettings];
    [assetReaderOutput retain];
    
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    
    [assetReader addOutput: assetReaderOutput];
    
    //last check
    if (![assetReader startReading]) {
        NSLog(@"Cannot start reading");
        return;
    }
    
    //set up the temp buffer
    
    
    [pool drain]; 
}

- (void)setupRemoteIOAudioUnit
{
    OSStatus status;
    AudioComponentInstance audioUnit;
    
    //describe the audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    //get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    //get audio unit
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    UInt32 flag = 1;
    //enable the audio unit for playback
    status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, kOutputBus, &flag, sizeof(flag));
    
    AudioStreamBasicDescription audioFormat;
    ASBDSetAUCanonical(&audioFormat, 2, NO);
    audioFormat.mSampleRate = 44100.0;
    
    //apply format
    status = AudioUnitSetProperty(audioUnit, 
                                  kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Output, 
                                  kInputBus, 
                                  &audioFormat, 
                                  sizeof(audioFormat));
    CheckError(status, "Cannot apply format to input bus");
    status = AudioUnitSetProperty(audioUnit, 
                                  kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Input, 
                                  kOutputBus, 
                                  &audioFormat, 
                                  sizeof(audioFormat));
    CheckError(status, "cannot apply format to output bus");
    
    // Set output callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = self;
    status = AudioUnitSetProperty(audioUnit, 
                                  kAudioUnitProperty_SetRenderCallback, 
                                  kAudioUnitScope_Global, 
                                  kOutputBus,
                                  &callbackStruct, 
                                  sizeof(callbackStruct));

    CheckError(status, "Cannot set input callback");
    
    status = AudioUnitInitialize(audioUnit);
    CheckError(status, "Cannot initialise audio unit");
    
    NSLog(@"Attempting to start audio unit...");
    status = AudioOutputUnitStart(audioUnit);
    CheckError(status, "cannot start audio unit");
    

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

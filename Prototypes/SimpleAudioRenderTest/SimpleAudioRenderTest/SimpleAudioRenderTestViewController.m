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
    
    // Allocate buffer
    buffer = (SInt16*)malloc(sizeof(SInt16) * kBufferLength);
    
    // Initialise record
    TPCircularBufferInit(&bufferRecord, kBufferLength);
    bufferRecordLock = [[NSLock alloc] init];
    
    NSLog(@"setting up audio file...");
    [self setupAudioFileUsingEAFS];
    NSLog(@"loading the audio file...");
    [self loadAudioFileUsingEAFS];
    NSLog(@"setting up audio unit...");
    [self setupRemoteIOAudioUnit];
}

//called by the audioFileCallback when some silence is needed
static void SilenceData(AudioBufferList *inData)
{
	for (UInt32 i=0; i < inData->mNumberBuffers; i++)
		memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
    
    NSLog(@"rendering silence...");
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
    
    SimpleAudioRenderTestViewController *this = (SimpleAudioRenderTestViewController *)inRefCon;
    AudioSampleType *in = this->bufList.mBuffers[0].mData;
    AudioSampleType *out = (AudioSampleType *)ioData->mBuffers[0].mData;
    
    UInt32 sample = this->currentFrameNum * this->asbd.mChannelsPerFrame;
    
    // make sure we don't attempt to render more data than we have available in the source buffers
    // if one buffer is larger than the other, just render silence for that bus until we loop around again
    if ((this->currentFrameNum + inNumberFrames) > this->numFrames) {
        UInt32 offset = (this->currentFrameNum + inNumberFrames) - this->numFrames;
        if (offset < inNumberFrames) {
            // copy the last bit of source
            SilenceData(ioData);
            memcpy(out, &in[sample], ((inNumberFrames - offset) * this->asbd.mBytesPerFrame));
            printf("Rendering out the last bits of data to bus number %lu\n", inBusNumber);
            return noErr;
        } else {
            // got no source data
            //NSLog(@"we have no source data because offset is %lu and inNumberFrames is %lu", offset, inNumberFrames);
            printf("We have no source data to provide to bus number %lu\n", inBusNumber);
            SilenceData(ioData);
            *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
            return noErr;
        }
    }
	
    memcpy(out, &in[sample], ioData->mBuffers[0].mDataByteSize);
    
    //printf("render input bus %ld sample %ld\n", inBusNumber, sample);
    this->currentFrameNum += inNumberFrames;
    
    return noErr;
    
}


- (void)setupAudioFileUsingEAFS
{
    //get url to audio file in bundle
    NSString *audioPathString = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"m4a"];
    NSURL *audioURL = [NSURL fileURLWithPath:audioPathString];
    
    //open the url in extended audio file services
    xafref = 0;
    error = ExtAudioFileOpenURL((CFURLRef)audioURL, &xafref);
    
    //get the format of the audio file
    AudioStreamBasicDescription fileFormat;
    UInt32 propSize = sizeof(fileFormat);
    error = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
    CheckError(error, "cannot get audio file data format");
    
    //create our output ASBD - we're also giving this to our mixer input
    ASBDSetCanonical(&mClientFormat, 2, true);						
    mClientFormat.mSampleRate = 44100.0;
    
    error = ExtAudioFileSetProperty(xafref, kExtAudioFileProperty_ClientDataFormat, sizeof(mClientFormat), &mClientFormat);
    CheckError(error, "cannot get kExtAudioFileProperty_ClientDataFormat");
    
    //get the file's length in sample frames
    UInt64 fileNumFrames = 0;
    propSize = sizeof(fileNumFrames);
    error = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileLengthFrames, &propSize, &fileNumFrames);
    CheckError(error, "cannot get file's length in sample frames");
    
    //NSLog(@"here numFrames is %llul and maxNumFrames is %lul and i is %d", numFrames, mUserData.maxNumFrames, i);
    
    //set up our buffer
    numFrames = fileNumFrames;
    asbd = mClientFormat;
    
    UInt32 samples = numFrames * asbd.mChannelsPerFrame;
    data = (AudioSampleType *)calloc(samples, sizeof(AudioSampleType));
    
    //set up a AudioBufferList to read data into
    
    bufList.mNumberBuffers = 1;
    bufList.mBuffers[0].mNumberChannels = asbd.mChannelsPerFrame;
    bufList.mBuffers[0].mData = data;
    bufList.mBuffers[0].mDataByteSize = samples * sizeof(AudioSampleType);
    
    }

- (void)loadAudioFileUsingEAFS
{
    // perform a synchronous sequential read of the audio data out of the file into our allocated data buffer
    UInt32 numPackets = numFrames;
    UInt32 cutNumPackets = numPackets / 3;
    printf("numPackets is %lu, dividing by 6 gives it %lu", numPackets, cutNumPackets);
    
    
    error = ExtAudioFileRead(xafref, &cutNumPackets, &bufList);
    if (error)
    {
        printf("ExtAudioFileRead result %ld %08X %4.4s\n", error, (unsigned int)error, (char*)&error); 
        free(data);
        data = 0;
        return;
    }

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

- (void)dealloc
{
    free(&mClientFormat);
    free(&asbd);
    free(&bufList);
    ExtAudioFileDispose(xafref);
    [super dealloc];
}

@end

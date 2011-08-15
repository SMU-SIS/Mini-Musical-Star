//
//  MixPlayerRecorder.m
//  SimpleAudioRenderTest
//
//  Created by Jun Kit Lee on 11/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "MixPlayerRecorder.h"

@implementation MixPlayerRecorder

#pragma mark - audio callbacks
static OSStatus micRenderCallback(void                          *inRefCon, 
                                  AudioUnitRenderActionFlags 	*ioActionFlags, 
                                  const AudioTimeStamp          *inTimeStamp, 
                                  UInt32 						inBusNumber, 
                                  UInt32 						inNumberFrames, 
                                  AudioBufferList               *ioData)
{
    MixPlayerRecorder *recorder = (MixPlayerRecorder*) inRefCon;
    OSStatus err = AudioUnitRender(recorder->rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	if (err) { printf("PerformThru: error %d\n", (int)err); return err; }
    
    return err;
}

static OSStatus audioFileCallback(void *inRefCon, 
                                 AudioUnitRenderActionFlags *ioActionFlags, 
                                 const AudioTimeStamp *inTimeStamp, 
                                 UInt32 inBusNumber, 
                                 UInt32 inNumberFrames, 
                                 AudioBufferList *ioData) 
{
    AudioFileRingBuffer *ringBuffer = (AudioFileRingBuffer *)inRefCon;
    
    AudioSampleType *out = (AudioSampleType *)ioData->mBuffers[0].mData;
    int samplesToCopy = ioData->mBuffers[0].mDataByteSize/sizeof(SInt16);
    
    SInt16 *buffer = [ringBuffer readFromRingBufferNumberOfSamples:samplesToCopy];
    memcpy(out, buffer, samplesToCopy * sizeof(SInt16));
    out += samplesToCopy;
    
    return noErr;
    
}

// this render notification (called by the AUGraph) is used to keep track of the frame number position in the source audio
static OSStatus renderNotification(void *inRefCon, 
                                   AudioUnitRenderActionFlags *ioActionFlags, 
                                   const AudioTimeStamp *inTimeStamp, 
                                   UInt32 inBusNumber, 
                                   UInt32 inNumberFrames, 
                                   AudioBufferList *ioData)
{
    MixPlayerRecorder *recorder = (MixPlayerRecorder *)inRefCon;
    
    if (*ioActionFlags & kAudioUnitRenderAction_PostRender) {
        
        //printf("post render notification frameNum %ld inNumberFrames %ld\n", userData->frameNum, inNumberFrames);
        
        recorder->frameNum += inNumberFrames;
        if (recorder->frameNum >= recorder->totalNumFrames) {
            //this will repeat the entire thing
            recorder->frameNum = 0;
            
        }
    }
    
    return noErr;
}

- (void)prepareAUGraph
{
    //create a new AUGraph
    error = NewAUGraph(&processingGraph);
    CheckError(error, "Cannot create AUGraph");
    
    //describe the output unit required (the RemoteIO)
    AudioComponentDescription rioDesc;
    rioDesc.componentType = kAudioUnitType_Output;
    rioDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    rioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    rioDesc.componentFlags = 0;
    rioDesc.componentFlagsMask = 0;
    
    //describe the mixer unit
    AudioComponentDescription mixerDesc;
    mixerDesc.componentType = kAudioUnitType_Mixer;
    mixerDesc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixerDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    mixerDesc.componentFlags = 0;
    mixerDesc.componentFlagsMask = 0;
    
    //create two nodes for the graph
    AUNode rioNode;
    AUNode mixerNode;
    
    //put the audio units (from the descriptions) into the nodes and add them to the graph
    error = AUGraphAddNode(processingGraph, &rioDesc, &rioNode);
    CheckError(error, "Cannot add remote i/o node to the graph");
    
    error = AUGraphAddNode(processingGraph, &mixerDesc, &mixerNode);
    CheckError(error, "Cannot add mixer node to the graph");
    
    //open the AUGraph to access the audio units to configure them
    error = AUGraphOpen(processingGraph);
    CheckError(error, "Cannot open AUGraph");
    
    //obtain the remote i/o unit from the corresponding node
    error = AUGraphNodeInfo(processingGraph, rioNode, NULL, &rioUnit);
    CheckError(error, "Cannot obtain the remote i/o unit from the corresponding node");
    
    //enable input (mic recording) on the remote io unit
    UInt32 one = 1;
    error = AudioUnitSetProperty(rioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(one));
    CheckError(error, "couldn't enable input on remote i/o unit");
    
    //create a render proc for the mic
    AURenderCallbackStruct inputProc;
    inputProc.inputProc = micRenderCallback;
    inputProc.inputProcRefCon = self;
    
    //set the render callback on the remote io unit
    error = AudioUnitSetProperty(rioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, 0, &inputProc, sizeof(inputProc));
    CheckError(error, "couldn't set render callback on remote i/o unit");
    
    AudioStreamBasicDescription micFormat;
    ASBDSetAUCanonical(&micFormat, 2, true);
    micFormat.mSampleRate = 44100;
    
    //apply the CAStreamBasicDescription to the remote i/o unit's input and output scope
    error = AudioUnitSetProperty(rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &micFormat, sizeof(micFormat));
    CheckError(error, "couldn't set remote i/o unit's output client format");
    
    error = AudioUnitSetProperty(rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &micFormat, sizeof(micFormat)); //1 or 0, this one?
    CheckError(error, "couldn't set remote i/o unit's input client format");
    
    
    
    
    
    //obtain the mixer unit from the corresponding node
    error = AUGraphNodeInfo(processingGraph, mixerNode, NULL, &mixerUnit);
    CheckError(error, "cannot obtain the mixer unit from the corresponding node");
    
    //start setting the mixer unit - find out how many file inputs are there by looking at the size of the soundbuffer
    UInt32 busCount = numInputFiles + 1;
    UInt32 micBus = numInputFiles;
    
    //set how many input buses the mixer unit has
    error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &busCount, sizeof(busCount));
    CheckError(error, "cannot set number of input buses for mixer unit");
    
    //increase maximum frames per size (for some screen locking thingy)
    UInt32 maxFramesPerSlice = 4096;
    error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(maxFramesPerSlice));
    CheckError(error, "cannot set max frames per size");
    
    //set the stream format for the mic input to mixer
    error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, micBus, &micFormat, sizeof(micFormat));
    CheckError(error, "cannot set mic format asbd on mixer input");
    
    for (int busNumber = 0; busNumber < micBus; busNumber++)
    {
        //now let's handle the audio file bus - set a render callback into mixer's input bus 1 - bus 0 will be handled later by the AUGraphConnectNodeInput
        AURenderCallbackStruct audioFileCallbackStruct;
        audioFileCallbackStruct.inputProc = &audioFileCallback;
        audioFileCallbackStruct.inputProcRefCon = [audioRingBuffers objectAtIndex:busNumber];
        
        error = AUGraphSetNodeInputCallback(processingGraph, mixerNode, busNumber, &audioFileCallbackStruct);
        CheckError(error, "Cannot set render callback for audio file on mixer input");
        
        //set the stream format for the audio file input bus (bus 0 of mixer input)
        error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, busNumber, &micFormat, sizeof(micFormat));
        CheckError(error, "Cannot set stream format for audio file input bus of mixer unit");
    }
    
    error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &micFormat, sizeof(micFormat));
    CheckError(error, "cannot set mixer output bus stream format");
    
    
    //now connect the nodes of the graph
    error = AUGraphConnectNodeInput(processingGraph, rioNode, 1, mixerNode, micBus);
    CheckError(error, "cannot connect remote io output node 1 to mixer input node 1");
    
    error = AUGraphConnectNodeInput(processingGraph, mixerNode, 0, rioNode, 0);
    CheckError(error, "cannot connect mixer output node 0 to remote io input node 0");
    
    error = AUGraphAddRenderNotify(processingGraph, renderNotification, self);
    CheckError(error, "cannot add AUGraphAddRenderNotify");
    
    //summary...
    CAShow(processingGraph);
    
    //initalize the graph
    error = AUGraphInitialize(processingGraph);
    CheckError(error, "cannot initialize processing graph");
    
    NSLog(@"initalizing graph finished");

}

#pragma mark - callable methods

- (MixPlayerRecorder *)initWithAudioFileURLs:(NSArray *)urls
{
    self = [super init];
    if (self) {
        
        //instantiate the ringbuffer array
        audioRingBuffers = [NSMutableArray arrayWithCapacity:urls.count];
        numInputFiles = urls.count;
        totalNumFrames = 0;
        
        //load the audio files into the ringbuffers
        [urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSURL *url = (NSURL *)obj;
            
            AudioFileRingBuffer *ringBuffer = [[AudioFileRingBuffer alloc] initWithAudioFile:url];
            [audioRingBuffers addObject:ringBuffer];
            
            if (ringBuffer.numFrames > totalNumFrames) totalNumFrames = ringBuffer.numFrames;
            
            [ringBuffer release];
        }];
    }
    
    return self;
}

- (void)play
{
    error = AUGraphStart(processingGraph);
    CheckError(error, "Cannot start AUGraph");
}

- (void)stop
{
    error = AUGraphStop(processingGraph);
    CheckError(error, "Cannot stop AUGraph");
}

- (void)seekTo:(CMTime)time
{
    
}

- (void)setVolume:(float)vol forBus:(int)busNumber
{
    
}

- (void)enableRecordingToFile:(NSURL *)filePath
{
    
}

- (void)setMicVolume:(float)vol
{
    
}

- (void)disableRecording
{
    
}

- (void)dealloc
{
    [audioRingBuffers release];
    [super dealloc];
}

@end
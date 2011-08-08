//
//  KaraokeRecorderController.m
//  ThirdAttempt
//
//  Created by Jun Kit on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KaraokeRecorderController.h"
const Float64 kGraphSampleRate = 44100.0;

@implementation KaraokeRecorderController
@synthesize assetReaderOutputs, mUserData;
#pragma mark utility functions

//called by the audioFileCallback when some silence is needed
static void SilenceData(AudioBufferList *inData)
{
	for (UInt32 i=0; i < inData->mNumberBuffers; i++)
		memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
    
    NSLog(@"rendering silence...");
}

#pragma mark callbacks and notifications

static OSStatus micRenderCallback(void                          *inRefCon, 
                                  AudioUnitRenderActionFlags 	*ioActionFlags, 
                                  const AudioTimeStamp          *inTimeStamp, 
                                  UInt32 						inBusNumber, 
                                  UInt32 						inNumberFrames, 
                                  AudioBufferList               *ioData)
{
    KaraokeRecorderController *userdata = (KaraokeRecorderController*) inRefCon;
    OSStatus err = AudioUnitRender(userdata->rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	if (err) { printf("PerformThru: error %d\n", (int)err); return err; }
    
    return err;
}

//called by the mixer unit to get audio file input

static OSStatus audioFileCallback(void                          *inRefCon, 
                                  AudioUnitRenderActionFlags 	*ioActionFlags, 
                                  const AudioTimeStamp          *inTimeStamp, 
                                  UInt32 						inBusNumber, 
                                  UInt32 						inNumberFrames, 
                                  AudioBufferList               *ioData)
{   
    SourceAudioBufferDataPtr userData = (SourceAudioBufferDataPtr)inRefCon;
    
    //need to -1 from the bus number to align ourselves with the soundBuffer arrays (it starts from 0, not 1)
    int targetBuffer = inBusNumber - 1;
    
    AudioSampleType *in = userData->soundBuffer[targetBuffer].data;
    AudioSampleType *out = (AudioSampleType *)ioData->mBuffers[inBusNumber].mData;
    
    UInt32 sample = userData->frameNum * userData->soundBuffer[targetBuffer].asbd.mChannelsPerFrame;
    //NSLog(@"here soundbuffer in bus number is %lul", inBusNumber);
    
    // make sure we don't attempt to render more data than we have available in the source buffers
    // if one buffer is larger than the other, just render silence for that bus until we loop around again
    if ((userData->frameNum + inNumberFrames) > userData->soundBuffer[0].numFrames) {
        UInt32 offset = (userData->frameNum + inNumberFrames) - userData->soundBuffer[targetBuffer].numFrames;
        if (offset < inNumberFrames) {
            // copy the last bit of source
            SilenceData(ioData);
            memcpy(out, &in[sample], ((inNumberFrames - offset) * userData->soundBuffer[targetBuffer].asbd.mBytesPerFrame));
            return noErr;
        } else {
            // got no source data
            NSLog(@"we have no source data because offset is %lu and inNumberFrames is %lu", offset, inNumberFrames);
            SilenceData(ioData);
            *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
            return noErr;
        }
    }
	
    memcpy(out, &in[sample], ioData->mBuffers[inBusNumber].mDataByteSize);
    
    //printf("render input bus %ld sample %ld\n", inBusNumber, sample);
    
    return noErr;
    
}

static OSStatus newAudioFileCallback(void                          *inRefCon, 
                                  AudioUnitRenderActionFlags 	*ioActionFlags, 
                                  const AudioTimeStamp          *inTimeStamp, 
                                  UInt32 						inBusNumber, 
                                  UInt32 						inNumberFrames, 
                                  AudioBufferList               *ioData)
{   
    KaraokeRecorderController *this = (KaraokeRecorderController *)inRefCon;
    
    //get a reference to the corresponding asset reader
    AVAssetReaderOutput *assetReader = [this.assetReaderOutputs objectAtIndex:inBusNumber - 1];
    
    //get a reference to the output buffer
    AudioSampleType *out = (AudioSampleType *)ioData->mBuffers[inBusNumber].mData;
    
    CMSampleBufferRef ref = [assetReader copyNextSampleBuffer];
    if (ref != nil)
    {
        CMItemCount countSamples = CMSampleBufferGetNumSamples(ref);
        UInt32 frameCount = countSamples;
        
        CMBlockBufferRef blockBuffer;
        AudioBufferList audioBufferList;
        
        //allocates new buffer memory
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(ref, NULL, &audioBufferList, sizeof(audioBufferList),NULL, NULL, 0, &blockBuffer);
        
        float* buffer = (float *) audioBufferList.mBuffers[0].mData;
        memcpy(out, &buffer, ioData->mBuffers[inBusNumber].mDataByteSize);
    }
    
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
    SourceAudioBufferDataPtr userData = (SourceAudioBufferDataPtr)inRefCon;
    
    if (*ioActionFlags & kAudioUnitRenderAction_PostRender) {
        
        //printf("post render notification frameNum %ld inNumberFrames %ld\n", userData->frameNum, inNumberFrames);
        
        userData->frameNum += inNumberFrames;
        if (userData->frameNum >= userData->maxNumFrames) {
            userData->frameNum = 0;
        }
    }
    
    return noErr;
}

#pragma mark AUGraph setup

-(void) loadAudioFilesInArray:(NSArray *)inputFilesArray
{
    mUserData.frameNum = 0;
    mUserData.maxNumFrames = 0;
    
    maxBuffers = inputFilesArray.count;
    
    assetReaderOutputs = [NSMutableArray arrayWithCapacity:maxBuffers];
    
    for (int i = 0; i < maxBuffers; i++)
    {
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:[inputFilesArray objectAtIndex:i] options:nil];
        NSError *assetError = nil;
        
        AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset error:&assetError];
        
        
        //top level pool required here
        //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        //create a dictionary of output audio settings
        NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                       [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                       [NSNumber numberWithInt:32], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                       [NSNumber numberWithBool:YES], AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                       [NSData data], AVChannelLayoutKey, nil];
        
        
        
        AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks audioSettings:audioSettings];
        
        //this retain is for?
        [assetReaderOutput retain];
        [assetReaderOutputs addObject:assetReaderOutput];
        
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
        
        
        
        /*
        
        ExtAudioFileRef xafref = 0;
        //open the audio file
        //CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, kInputFileLocation, kCFURLPOSIXPathStyle, false);
        error = ExtAudioFileOpenURL((CFURLRef)[inputFilesArray objectAtIndex:i], &xafref);
        CheckError(error, "Cannot open audio file");
        
        //CFRelease(inputFileURL);
        [[inputFilesArray objectAtIndex:i] release];
        
        //get an ASBD from it
        AudioStreamBasicDescription fileFormat;
        UInt32 propSize = sizeof(fileFormat);
        error = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
        CheckError(error, "cannot get audio file data format");
        
        //Sorry, wait until I implement ASBDPrint() in ASBDHelper.h can? :)
        //fileFormat.Print();
        
        //create our output ASBD - we're also giving this to our mixer input
        error = ExtAudioFileSetProperty(xafref, kExtAudioFileProperty_ClientDataFormat, sizeof(mClientFormat), &mClientFormat);
        CheckError(error, "cannot get kExtAudioFileProperty_ClientDataFormat");
        
        //get the file's length in sample frames
        UInt64 numFrames = 0;
        propSize = sizeof(numFrames);
        error = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileLengthFrames, &propSize, &numFrames);
        CheckError(error, "cannot get file's length in sample frames");
        
        // keep track of the largest number of source frames
        if (numFrames > mUserData.maxNumFrames) mUserData.maxNumFrames = numFrames;
        
        //NSLog(@"here numFrames is %llul and maxNumFrames is %lul and i is %d", numFrames, mUserData.maxNumFrames, i);
        
        //set up our buffer
        mUserData.soundBuffer[i].numFrames = numFrames;
        mUserData.soundBuffer[i].asbd = mClientFormat;
        
        UInt32 samples = numFrames * mUserData.soundBuffer[i].asbd.mChannelsPerFrame;
        mUserData.soundBuffer[i].data = (AudioSampleType *)calloc(samples, sizeof(AudioSampleType));
        
        //set up a AudioBufferList to read data into
        AudioBufferList bufList;
        bufList.mNumberBuffers = maxBuffers;
        bufList.mBuffers[i].mNumberChannels = mUserData.soundBuffer[i].asbd.mChannelsPerFrame;
        bufList.mBuffers[i].mData = mUserData.soundBuffer[i].data;
        bufList.mBuffers[i].mDataByteSize = samples * sizeof(AudioSampleType);
        
        // perform a synchronous sequential read of the audio data out of the file into our allocated data buffer
        UInt32 numPackets = numFrames;
        error = ExtAudioFileRead(xafref, &numPackets, &bufList);
        if (error)
        {
            printf("ExtAudioFileRead result %ld %08X %4.4s\n", error, (unsigned int)error, (char*)&error); 
            free(mUserData.soundBuffer[i].data);
            mUserData.soundBuffer[i].data = 0;
            return;
        }
        
        //close the file and dispose the ExtAudioFileRef
        ExtAudioFileDispose(xafref);
        
        */
        
    }

}

-(void)setupAudioFormats
{
    // client format audio goes into the mixer
    ASBDSetCanonical(&mClientFormat, 2, true);						
    mClientFormat.mSampleRate = kGraphSampleRate;
    //sorry, wait until I implement ASBDPrint() ok?
    //mClientFormat.Print();
    
    // output format
    ASBDSetAUCanonical(&mOutputFormat, 2, false);						
    mOutputFormat.mSampleRate = kGraphSampleRate;
    //sorry, wait until I implement ASBDPrint() ok?
    //mOutputFormat.Print();
}

-(void)setupAUGraph
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
    
    //use CAStreamBasicDescription to create a template for the ASBD -- let's not do this ok?
    /*
    CAStreamBasicDescription micFormat;
    micFormat.SetAUCanonical(2, false);
    micFormat.mSampleRate = 44100;
     */
    
    AudioStreamBasicDescription micFormat;
    ASBDSetAUCanonical(&micFormat, 2, false);
    micFormat.mSampleRate = 44100;
    
    //apply the CAStreamBasicDescription to the remote i/o unit's input and output scope
    error = AudioUnitSetProperty(rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &micFormat, sizeof(micFormat));
    CheckError(error, "couldn't set remote i/o unit's output client format");
    
    error = AudioUnitSetProperty(rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &micFormat, sizeof(micFormat)); //1 or 0, this one?
    CheckError(error, "couldn't set remote i/o unit's input client format");
    
    
    
    
    
    //obtain the mixer unit from the corresponding node
    error = AUGraphNodeInfo(processingGraph, mixerNode, NULL, &mixerUnit);
    CheckError(error, "cannot obtain the mixer unit from the corresponding node");
    
    //start setting the mixer unit
    UInt32 busCount = maxBuffers + 1; //total number of audio file callbacks + mic input
    UInt32 micBus = 0;
    
    //increase maximum frames per size (for some screen locking thingy)
    UInt32 maxFramesPerSlice = 4096;
    error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(maxFramesPerSlice));
    CheckError(error, "cannot set max frames per size");
    
    //set the stream format for the mic input to mixer
    error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, micBus, &micFormat, sizeof(micFormat));
    CheckError(error, "cannot set mic format asbd on mixer input");
    
    for (int i = 1; i < busCount; i++)
    {
        UInt32 audioFileBus = i;
        
        //set how many input buses the mixer unit has
        error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &busCount, sizeof(busCount));
        CheckError(error, "cannot set number of input buses for mixer unit");
        
        //now let's handle the audio file bus - set a render callback into mixer's input bus 1,2,3... - bus 0 will be handled later by the AUGraphConnectNodeInput
        AURenderCallbackStruct audioFileCallbackStruct;
        audioFileCallbackStruct.inputProc = &audioFileCallback;
        audioFileCallbackStruct.inputProcRefCon = &self;
        
        error = AUGraphSetNodeInputCallback(processingGraph, mixerNode, audioFileBus, &audioFileCallbackStruct);
        CheckError(error, "Cannot set render callback for audio file on bus 1 of mixer input");
        
        //set the stream format for the audio file input bus (bus 1 of mixer input)
        error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 1, &mClientFormat, sizeof(mClientFormat));
        CheckError(error, "Cannot set stream format for audio file input bus of mixer unit");
        
    }
    
    //set the mixer unit's output sample rate - OLD CODE
    /*
     Float64 graphSampleRate;
     graphSampleRate = 44100.0;
     error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, 0, &graphSampleRate, sizeof(graphSampleRate));
     CheckError(error, "cannot set output sample rate for mixer unit");
     */
    
    error = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &mOutputFormat, sizeof(mOutputFormat));
    CheckError(error, "cannot set mixer output bus stream format");
    
    
    //now connect the nodes of the graph
    error = AUGraphConnectNodeInput(processingGraph, rioNode, 1, mixerNode, 0);
    CheckError(error, "cannot connect remote io output node 1 to mixer input node 0");
    
    error = AUGraphConnectNodeInput(processingGraph, mixerNode, 0, rioNode, 0);
    CheckError(error, "cannot connect mixer output node 0 to remote io input node 0");
    
    error = AUGraphAddRenderNotify(processingGraph, renderNotification, &mUserData);
    CheckError(error, "cannot add AUGraphAddRenderNotify");
    
    //summary...
    CAShow(processingGraph);
    
    //initalize the graph
    error = AUGraphInitialize(processingGraph);
    CheckError(error, "cannot initialize processing graph");
    
    NSLog(@"initalizing graph finished");
        

}



#pragma mark user-callable functions
-(KaraokeRecorderController*)initWithAudioFileArray:(NSArray *)audioFileArray
{
    self = [super init];
    if ( self ) {
        [self setupAudioFormats];
        //[self loadAudioFile:audioFileURL];
        [self performSelectorInBackground:@selector(loadAudioFilesInArray:) withObject:audioFileArray];
        [self setupAUGraph];
        
        recordingEnabled = NO;
    }
    return self;
}

-(void)startRecording
{
    
    error = AUGraphStart(processingGraph);
    CheckError(error, "cannot start AUGraph");
    
    NSLog(@"AUgraph started");

}

-(void)stopRecording
{
    error = AUGraphStop(processingGraph);
    CheckError(error, "cannot stop AUGraph");
    
    //reset the audio file position
    mUserData.frameNum = 0;
    
    [rioCapturer stop];
    [rioCapturer close];
    
    recordingEnabled = NO;
}

-(void)changeInputVolumeForBus:(UInt32)inputNum value:(AudioUnitParameterValue)value
{
    AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, inputNum, value, 0);
    //CheckError("error", "cannot change volume");
}

-(void)enableRecordingWithPath:(CFURLRef)outputFileURL forBus:(int)busNumber
{
    rioCapturer = [[BoomzAUOutputCapturer alloc]
                   initWithAudioUnit:rioUnit OutputURL:outputFileURL AudioFileTypeID:'caff' forBusNumber:busNumber];
    [rioCapturer start];
    recordingEnabled = YES;

}


#pragma mark cleanup
-(void)dealloc
{
    [rioCapturer dealloc];
    DisposeAUGraph(processingGraph);
    [super dealloc];
}

@end

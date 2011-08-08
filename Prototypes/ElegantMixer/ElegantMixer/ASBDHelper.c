//
//  ASBDHelper.c
//  ThirdAttempt
//
//  Created by Jun Kit on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ASBDHelper.h"

void ASBDSetAUCanonical(AudioStreamBasicDescription* asbd, UInt32 nChannels, bool interleaved)
{
    
    asbd->mFormatID = kAudioFormatLinearPCM;
#if CA_PREFER_FIXED_POINT
    asbd->mFormatFlags = kAudioFormatFlagsCanonical | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
#else
    asbd->mFormatFlags = kAudioFormatFlagsCanonical;
#endif
    asbd->mChannelsPerFrame = nChannels;
    asbd->mFramesPerPacket = 1;
    asbd->mBitsPerChannel = 8 * SizeOf32(AudioUnitSampleType);
    if (interleaved)
        asbd->mBytesPerPacket = asbd->mBytesPerFrame = nChannels * SizeOf32(AudioUnitSampleType);
    else {
        asbd->mBytesPerPacket = asbd->mBytesPerFrame = SizeOf32(AudioUnitSampleType);
        asbd->mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
    }

}


void ASBDSetCanonical(AudioStreamBasicDescription* asbd, UInt32 nChannels, bool interleaved)
{
    asbd->mFormatID = kAudioFormatLinearPCM;
    int sampleSize = SizeOf32(AudioSampleType);
    asbd->mFormatFlags = kAudioFormatFlagsCanonical;
    asbd->mBitsPerChannel = 8 * sampleSize;
    asbd->mChannelsPerFrame = nChannels;
    asbd->mFramesPerPacket = 1;
    if (interleaved)
        asbd->mBytesPerPacket = asbd->mBytesPerFrame = nChannels * sampleSize;
    else {
        asbd->mBytesPerPacket = asbd->mBytesPerFrame = sampleSize;
        asbd->mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
    }

}

void ASBDPrint(AudioStreamBasicDescription* asbd)
{
    
}
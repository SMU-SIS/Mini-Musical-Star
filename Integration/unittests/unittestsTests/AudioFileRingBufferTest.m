//
//  AudioFileRingBufferTest.m
//  UnitTests
//
//  Created by Jun Kit Lee on 22/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "AudioFileRingBufferTest.h"

@implementation AudioFileRingBufferTest
@synthesize buffer;
#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void)testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

#pragma mark actual test cases
- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:@"guitar" ofType:@"mp3"];
    buffer = [[AudioFileRingBuffer alloc] initWithAudioFile:[NSURL fileURLWithPath:audioFile]];
}

- (void)tearDown
{
    // Tear-down code here.
    [buffer release];
    [super tearDown];
}

- (void)testReadyToRead
{
    //printf("lla is %llu\n", buffer.numFrames);
    STAssertTrue(buffer.canStartReading, @"AudioFileRingBuffer cannot start reading");
}

- (void)testAudioFileReadCorrectly
{
    UInt64 result = 1324800;
    STAssertEquals(result, buffer.numFrames, @"buffer.numFrames do not match the correct number (supposed to be 1324800 for guitar.mp3)");
}

- (void)testRingBufferReturnsValidMemoryAddress
{
    SInt16 *audioData = [buffer readFromRingBufferNumberOfSamples:512];
    //check if the pointer points to a non-zero block of memory (not 0x0)
    if (audioData == 0x0) STFail(@"Pointer returns a nil memory address");
    else
    {
        printf("audio buffer address is %p\n", audioData);
        STAssertTrue(true, @"Pointer returns a valid memory address");
    }
}

- (void)testSuccessiveRingBufferReading
{
    //this test ensures that we read enough samples for the ringbuffer to empty itself and fill itself up again
    for (int i = 0; i < 20; i++)
    {
        SInt16 *audioData = [buffer readFromRingBufferNumberOfSamples:512];
        //check if the pointer points to a non-zero block of memory (not 0x0)
        if (audioData == 0x0) STFail(@"Pointer returns a nil memory address");
    }
    
    //if the for loop succeeds, means successive reads are fine, pass the test
    STAssertTrue(true, @"Ringbuffer can handle successive reads");
}

- (void)testCurrentFrameNumIsCorrect
{
    //this test ensures that after reading 21 times of 512 samples each, the currentFrameNum is still accurate
    for (int i = 0; i < 21; i++)
    {
        SInt16 *audioData = [buffer readFromRingBufferNumberOfSamples:512];
        //check if the pointer points to a non-zero block of memory (not 0x0)
        if (audioData == 0x0) STFail(@"Pointer returns a nil memory address");
    }
    
    //printf("current frame num is %llu\n", buffer.currentFrameNum);
    UInt64 result = 6144;
    STAssertEquals(result, buffer.currentFrameNum, @"currentFrameNum does not match expected value");
}

- (void)testSeekToNewTargetFrame
{
    [buffer moveReadPositionOfAudioFileToFrame:20000];
    UInt64 result = 20000;
    STAssertEquals(result, buffer.currentFrameNum, @"Ringbuffer does not report expected current frame number after seek");
}

- (void)testResetRingBuffer
{
    [buffer moveReadPositionOfAudioFileToFrame:20000];
    UInt64 expectedNewFrameNum = 20000;
    if (buffer.currentFrameNum == expectedNewFrameNum) 
    {
        [buffer reset];
        UInt64 result = 0;
        STAssertEquals(result, buffer.currentFrameNum, @"Ringbuffer does not reset to the 0th frame upon calling reset");
    }
    
    else STFail(@"Ringbuffer does not report expected new current frame number after seek");
    
    
}

#endif

@end

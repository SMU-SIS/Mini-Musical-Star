//
//  MixPlayerRecorderTest.m
//  UnitTests
//
//  Created by Jun Kit Lee on 22/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "MixPlayerRecorderTest.h"

@implementation MixPlayerRecorderTest
@synthesize player, guitar, bass, drums, keys, vocals;

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

//- (void)testAppDelegate {
//    
//    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
//    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
//    
//}

#else                           // all code under test must be linked into the Unit Test bundle

//- (void)testMath {
//    
//    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
//    
//}

#pragma mark actual test cases

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    guitar = [[NSBundle mainBundle] pathForResource:@"guitar" ofType:@"mp3"];
    keys = [[NSBundle mainBundle] pathForResource:@"keys" ofType:@"mp3"];
    vocals = [[NSBundle mainBundle] pathForResource:@"vocals" ofType:@"mp3"];
    bass = [[NSBundle mainBundle] pathForResource:@"bass" ofType:@"mp3"];
    drums = [[NSBundle mainBundle] pathForResource:@"drums" ofType:@"mp3"];
    
    NSArray *fiveArray = [NSArray arrayWithObjects:[NSURL fileURLWithPath:guitar], [NSURL fileURLWithPath:keys], [NSURL fileURLWithPath:vocals],[NSURL fileURLWithPath:bass],[NSURL fileURLWithPath:drums], nil];
    player = [[MixPlayerRecorder alloc] initWithAudioFileURLs:fiveArray];
}

- (void)tearDown
{
    // Tear-down code here.
    [guitar release];
    [keys release];
    [vocals release];
    [bass release];
    [drums release];
    [player stop];
    //[NSThread sleepForTimeInterval:1];
    //[player release]; //if you release it will crash for I don't know what reason
    [super tearDown];
}

//- (void)testCorrectNumberOfInputFiles
//{
//
//    
//    //try with 2 files first
//    NSArray *twoArray = [NSArray arrayWithObjects:[NSURL fileURLWithPath:guitar], [NSURL fileURLWithPath:keys],nil];
//    MixPlayerRecorder *testPlayer;
//    testPlayer = [[MixPlayerRecorder alloc] initWithAudioFileURLs:twoArray];
//    
//    if (testPlayer.numInputFiles == 2)
//    {
//        [testPlayer release];
//        
//        //now try with 3 files
//        NSArray *threeArray = [NSArray arrayWithObjects:[NSURL fileURLWithPath:guitar], [NSURL fileURLWithPath:keys], [NSURL fileURLWithPath:vocals], nil];
//        testPlayer = [[MixPlayerRecorder alloc] initWithAudioFileURLs:threeArray];
//        
//        STAssertEquals(3, testPlayer.numInputFiles, @"numInputFiles did not return the expected value (3), actual value is %i", testPlayer.numInputFiles);
//    }
//    
//    else STFail(@"numInputFiles did not return the expected value (2), actual value is %i", testPlayer.numInputFiles);
//    
//    [testPlayer release];
//    
//}
//
//- (void)testCanPlay
//{
//    [player play];
//    
//    [NSThread sleepForTimeInterval:1];
//    //check both the bool flag and the AUGraph directly
//    if (player.isPlaying)
//    {
//        bool result = [player checkGraphStatus];
//        STAssertTrue(result, @"Graph should be playing, but apparently not.");
//    }
//    
//    else {
//        STFail(@"bool flag shows false when player should be playing");
//    }
//    
//}
//
//- (void)testCanStop
//{
//    if ([player checkGraphStatus])
//    {
//        [player stop];
//        if (!player.isPlaying)
//        {
//            bool result = [player checkGraphStatus];
//            STAssertTrue((!result), @"Graph should not be playing, but apparently is.");
//        }
//        
//        else {
//            STFail(@"bool flag shows true when player should not be playing");
//        }
//
//    }
//}
//
//- (void)testCanSeek
//{
//    if (!player.isPlaying) [player play];
//    
//    int originalFrameNum = player.frameNum;
//    [player seekTo:20];
//    [NSThread sleepForTimeInterval:1];
//    STAssertEquals(true, (originalFrameNum != player.frameNum), @"new frameNum is the same as original");
//}
//
//- (void)testCanChangeVolume
//{
//    //just change bus 0 and 1's volume
//    [player setVolume:0.1 forBus:0];
//    [player setVolume:0.1 forBus:1];
//    STAssertEquals((float)0.1, [player getVolumeForBus:0], @"bus 0 volume is not expected volume after setting");
//    STAssertEquals((float)0.1, [player getVolumeForBus:1], @"bus 1 volume is not expected volume after setting");
//}
//
////- (void) testCanSeekBackProperlyWhenEndOfFileIsReached
////{
////    [player play];
////    [player seekTo:(player.totalNumFrames - 10)];
////    
////    [NSThread sleepForTimeInterval:1];
////    
////    //start playing again
////    [player play];
////    [NSThread sleepForTimeInterval:1];
////    UInt32 result = 10000;
////    STAssertTrue((player.frameNum < result), @"Player should play from beginning but the current frame number (%lu) looks a bit too large", player.frameNum);
////    
////    
////}
//
//- (void)testCanRecord
//{
//    NSArray *fiveArray = [NSArray arrayWithObjects:[NSURL fileURLWithPath:guitar], [NSURL fileURLWithPath:keys], [NSURL fileURLWithPath:vocals],[NSURL fileURLWithPath:bass],[NSURL fileURLWithPath:drums], nil];
//    MixPlayerRecorder *testRecorder = [[MixPlayerRecorder alloc] initWithAudioFileURLs:fiveArray];
//    
//    NSString *tempFile = [NSTemporaryDirectory() stringByAppendingString:@"test.caf"];
//    [testRecorder enableRecordingToFile:[NSURL fileURLWithPath:tempFile]];
//     
//    [testRecorder play];
//    [NSThread sleepForTimeInterval:1];
//    [testRecorder stop];
//    
//    AVAsset *recordedAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:tempFile] options:nil];
//    STAssertTrue(recordedAsset.isPlayable, @"the recorded file isn't playable as reported by AVFoundation");
//    
//    //delete the temp file
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error;
//    BOOL fileExists = [fileManager fileExistsAtPath:tempFile];
//    
//    if (fileExists)
//    {
//        BOOL success = [fileManager removeItemAtPath:tempFile error:&error];
//        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
//    }
//    
//    [testRecorder release];
//    
//}



#endif

@end

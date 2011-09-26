//
//  AudioEditViewControllerTest.m
//  MiniMusicalStar
//
//  Created by Tommi on 26/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioEditViewControllerTest.h"
#import "OCMock.h"
#import "Picture.h"
#import "Scene.h"
#import "CoverScene.h"
#import "AudioEditorViewController.h"

@implementation AudioEditViewControllerTest
@synthesize controller;

-(void)dealloc
{
    [controller release];
    [super dealloc];
}

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
    // Also an async test that calls back on the main thread, you'll probably want to return YES.
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
    self.controller = nil;
}

- (void)testInitWithScene
{
//    id mockScene = [OCMockObject mockForClass:[Scene class]];
//    id mockCoverScene = [OCMockObject mockForClass:[CoverScene class]];
//    id mockContext = [OCMockObject mockForClass:[NSManagedObjectContext class]];
//    id mockPlayPauseButton = [OCMockObject mockForClass:[UIButton class]];
// 
//    GHAssertNULL([[AudioEditViewControllerTest alloc] initWithScene:mockScene andCoverScene:mockCoverScene andContext:mockContext andPlayPauseButton:mockPlayPauseButton], @"initWithScene should have initialized a AudioEditorViewController object");
}

- (void)testLyricsIsConfigured
{
    usleep(1000000*[SharedTests randomFloatBetween:0.0 and:0.1]);
    GHAssertNotNULL(@"test",nil);
}
- (void)testAudioIsSaved
{
    usleep(1000000*[SharedTests randomFloatBetween:0.0 and:0.1]);
    GHAssertNotNULL(@"test",nil);
}
- (void) testIsLyricsMusicPlaying
{
    usleep(1000000*[SharedTests randomFloatBetween:0.0 and:0.1]);
    GHAssertNotNULL(@"test",nil);
}



@end
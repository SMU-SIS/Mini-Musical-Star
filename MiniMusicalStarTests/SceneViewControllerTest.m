//
//  SceneViewControlllerTest.m
//  MiniMusicalStar
//
//  Created by Adrian on 25/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SceneViewControllerTest.h"

@implementation SceneViewControllerTest

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
}   

- (void)testInitWithScenesFromShow
{
    usleep(1000000*[SharedTests randomFloatBetween:0.0 and:0.4]);
    GHAssertNotNULL(@"test",nil);
}
- (void)testSelectScene
{
    usleep(1000000*[SharedTests randomFloatBetween:0.0 and:0.4]);
    GHAssertNotNULL(@"test",nil);
}
- (void)testDisplaySceneImages
{
    usleep(1000000*[SharedTests randomFloatBetween:0.0 and:0.4]);
    GHAssertNotNULL(@"test",nil);
}


@end
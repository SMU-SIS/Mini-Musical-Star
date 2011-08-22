//
//  MixPlayerRecorderTest.h
//  UnitTests
//
//  Created by Jun Kit Lee on 22/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  Define USE_APPLICATION_UNIT_TEST to 0 if the unit test code is designed to be linked into an independent test executable.

#define USE_APPLICATION_UNIT_TEST 0

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "MixPlayerRecorder.h"
#import <AVFoundation/AVFoundation.h>

//#import "application_headers" as required

@interface MixPlayerRecorderTest : SenTestCase

@property (retain, nonatomic) MixPlayerRecorder *player;
@property (retain, nonatomic) NSString *guitar;
@property (retain, nonatomic) NSString *bass;
@property (retain, nonatomic) NSString *drums;
@property (retain, nonatomic) NSString *keys;
@property (retain, nonatomic) NSString *vocals;

#if USE_APPLICATION_UNIT_TEST
- (void)testAppDelegate;       // simple test on application
#else
- (void)testMath;              // simple standalone test
#endif

@end

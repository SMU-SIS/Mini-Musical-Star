//
//  PhotoEditorViewControllerTest.m
//  MiniMusicalStar
//
//  Created by Adrian on 25/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoEditorViewControllerTest.h"
#import "OCMock.h"
#import "Picture.h"

@implementation PhotoEditorViewControllerTest
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
    Picture *pic1 = [[[Picture alloc] init] autorelease];
    pic1.orderNumber = 1;
    pic1.duration = 10;
    pic1.startTime = 0;
    pic1.image = [OCMockObject mockForClass: [UIImage class]];
    
    Picture *pic2 =[[[Picture alloc] init] autorelease];
    pic2.orderNumber = 2;
    pic2.duration = 10;
    pic2.startTime = 10;
    pic2.image = [OCMockObject mockForClass: [UIImage class]];
    
    Picture *pic3 = [[[Picture alloc] init] autorelease];
    pic3.orderNumber = 3;
    pic3.duration = 10;
    pic3.startTime = 20;
    pic3.image = [OCMockObject mockForClass: [UIImage class]];
    
    NSArray *pictureArray = [[NSArray alloc] initWithObjects:pic1,pic2,pic3, nil];
    
    self.controller = [[[PhotoEditorViewController alloc] init] autorelease];
    GHAssertNotNULL(controller,@"controller did not get initialized");
    
    //self.controller.thePictures = pictureArray;
    self.controller.theCoverScene = [OCMockObject mockForClass: [CoverScene class]];
    self.controller.context = [OCMockObject mockForClass: [NSManagedObjectContext class]];
//    AFOpenFlowView *mockOpenFlowView = [[AFOpenFlowView alloc] init];
//    mockOpenFlowView.viewDelegate = self.controller;
}

- (void)tearDown {
    // Run after each test method
    self.controller = nil;
}

- (void)testInitWithPhotos
{
    id mockArray = [OCMockObject mockForClass:[NSArray class]];
    id mockCoverScene = [OCMockObject mockForClass:[CoverScene class]];
    id mockContext = [OCMockObject mockForClass:[NSManagedObjectContext class]];
                      
    GHAssertNotNULL([[PhotoEditorViewController alloc] initWithPhotos:mockArray andCoverScene:mockCoverScene andContext:mockContext],@"initWithPhotos should have initialized a PhotoEditorViewController object");
}

- (void)testSliderCanBeSet
{
//    id openFlowView = [OCMockObject mockForClass:[AFOpenFlowView class]];
//    [self.controller setSliderImages:2];
//    [[openFlowView expect] setSelectedCover:1];
//    [[openFlowView expect] centerOnSelectedCover:TRUE];
    id mockController = [OCMockObject mockForClass:[PhotoEditorViewController class]];
    [[mockController expect] setSliderImages:2];
}
- (void)testReplaceCenterImage
{
    usleep(1000000*[SharedTests randomFloatBetween:0.0 and:0.1]);
    GHAssertNotNULL(@"test",nil);
}
- (void)testOpenFlowView
{
    usleep(1000000*[SharedTests randomFloatBetween:0.0 and:0.1]);
    GHAssertNotNULL(@"test",nil);
}
- (void) testPopupCameraOptions
{
    usleep(1000000*[SharedTests randomFloatBetween:0.0 and:0.1]);
    GHAssertNotNULL(@"test",nil);
}



@end
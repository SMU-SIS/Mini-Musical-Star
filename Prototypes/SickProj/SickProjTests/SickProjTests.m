//
//  SickProjTests.m
//  SickProjTests
//
//  Created by Tommi on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SickProjTests.h"

#import <OCMock/OCMock.h>

@implementation SickProjTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    stud1 = [[NSStudent alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

//- (void)testExample/Volumes/Data/tommi/App Dev iOS/SickProj/SickProj.xcodeproj
//{
//    STFail(@"Unit tests are not implemented yet in SickProjTests");
//}

-(void) testDefaultStudentName {
    NSString* s1name = [stud1 name];
    
    //trying check if the strings are equal
    //1st argument: the expected value
    //2nd argument: the given value
    //3rd argument: error message
    //Note: to compare strings, cannot use STAssertEquals
    STAssertEqualObjects(@"default name11111", s1name, @"Name is not equal but Tommi is awesome.");
    
}

-(void) testDefaultStudentFaculty {
    NSString* s1faculty = [stud1 faculty];
    
    STAssertEqualObjects(@"SIS11111", s1faculty, @"Faculty is not equal but Tommi is still very awesome.");
    
}


-(void) testOCMockPass {
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
    
    NSString *returnValue = [mock lowercaseString];
    STAssertEqualObjects(@"mocktest", returnValue, @"Should have returned the expected string");
    
}

- (void)testOCMockFail {
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
    
    NSString *returnValue = [mock lowercaseString];
    STAssertEqualObjects(@"thisIsTheWrongValueToCheck", 
                         returnValue, @"Should have returned the expected string.");
}
 

@end

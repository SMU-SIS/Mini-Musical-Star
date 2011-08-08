//
//  NSStudent.m
//  PlayUnitTesting
//
//  Created by Tommi on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSStudent.h"


@implementation NSStudent

//@synthesize name;
//@synthesize faculty;

-(id) init {
    //if statement is verifying that the initialization was successful
    if ((self = [super init])) { //assign result of [super init] to self, asking the superclass to do it's own initialization,
        [self setName:@"default name"];
        [self setFaculty:@"SIS"];
    }
    return self;
}

//dealloc is called when the object is being removed from the memory
-(void) dealloc {
    [name release];
    [faculty release];
    [super dealloc]; //important, asking superclass to cleanup, if not done, will have memory leak
}

-(NSString*) name {
    return name;
}

-(NSString*) faculty {
    return faculty;
}

-(void) setName: (NSString*)input {
    [name autorelease]; //tell ObjC to release the object soon
    name = [input retain]; //retain the new object
}

-(void) setFaculty:(NSString *)input {
    [faculty autorelease];
    faculty = [input retain];
}




@end

//
//  NSStudent.h
//  PlayUnitTesting
//
//  Created by Tommi on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSStudent : NSObject {
    NSString* name;
    NSString* faculty;
    
}

-(NSString*) name;
-(NSString*) faculty;

-(void) setName: (NSString*) input;
-(void) setFaculty: (NSString*) input;

//@property (retain) NSString* name;
//@property (retain) NSString* faculty;


@end

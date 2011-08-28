//
//  Picture.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Picture.h"

@implementation Picture
@synthesize title, path, startTime, duration, cueList;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [title release];
    [path release];
    [startTime release];
    [duration release];
    [cueList release];
    [super dealloc];
}


@end

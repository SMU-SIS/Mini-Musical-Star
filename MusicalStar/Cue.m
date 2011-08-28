//
//  Cue.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Cue.h"

@implementation Cue
@synthesize content, time, duration, type;

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
    [content release];
    [time release];
    [duration release];
    [type release];
    [super dealloc];
}


@end

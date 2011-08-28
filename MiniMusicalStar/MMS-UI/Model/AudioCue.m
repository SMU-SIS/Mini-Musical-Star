//
//  Cue.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioCue.h"

@implementation AudioCue
@synthesize content, time, duration, type;

- (AudioCue *)initWithPropertyDictionary: (NSDictionary *) pDictionary
{
    self = [super init];
    if (self) {
        content = [pDictionary objectForKey:@"content"];
        time = [pDictionary objectForKey:@"time"];
        type= [pDictionary objectForKey:@"type"];
        duration = [pDictionary objectForKey:@"duration"];
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

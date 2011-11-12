//
//  Cue.m
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Cue.h"

@implementation Cue
@synthesize cueHash, startTime, endTime, content, contentPath;

- (void)dealloc
{
    [cueHash release];
    [content release];
    [contentPath release];
    [super dealloc];
}

- (id)initWithCueHash: (NSString *)aCueHash startTime: (NSNumber *)aStartTime endTime: (NSNumber *)anEndTime content: (NSString *)aContent contentPath: (NSURL *)aContentPath
{
    self = [super init];
    if (self)
    {
        self.cueHash = aCueHash;
        self.startTime = [aStartTime intValue];
        self.endTime = [anEndTime intValue];
        self.content = aContent;
        self.contentPath = aContentPath;
    }
    
    return self;
}

@end

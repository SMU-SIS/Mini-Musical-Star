//
//  Audio.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Audio.h"

@implementation Audio
@synthesize title, path, replaceable, duration, cueList;

- (Audio *)initWithPropertyDictionary: (NSDictionary *) pDictionary
{
    self = [super init];
    if (self) {
        title = [pDictionary valueForKey:@"title"];
        path = [pDictionary valueForKey:@"path"];
        replaceable = [pDictionary valueForKey:@"repleaceable"];
        duration = [pDictionary valueForKey:@"duration"];
        cueList = [pDictionary valueForKey:@"cueList"];
        
    }
    
    return self;
}

- (void)dealloc
{
    [title release];
    [path release];
    [duration release];
    [cueList release];
    [super dealloc];
}

@end

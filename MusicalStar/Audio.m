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
        title = [pDictionary objectForKey:@"title"];
        path = [pDictionary objectForKey:@"path"];
        replaceable = [pDictionary objectForKey:@"repleaceable"];
        duration = [pDictionary objectForKey:@"duration"];
        cueList = [pDictionary objectForKey:@"cueList"];
        
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

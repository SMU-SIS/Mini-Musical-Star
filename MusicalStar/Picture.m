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

- (Picture *)initWithPropertyDictionary: (NSDictionary *) pDictionary
{
    self = [super init];
    if (self) {
        title = [pDictionary objectForKey:@"title"];
        path = [pDictionary objectForKey:@"path"];
        startTime = [pDictionary objectForKey:@"startTime"];
        duration = [pDictionary objectForKey:@"duration"];
        cueList = [pDictionary objectForKey:@"cueList"];
        
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

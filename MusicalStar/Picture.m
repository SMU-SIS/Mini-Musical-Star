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
        NSArray *cueArray = [pDictionary objectForKey:@"cues"];
        cueList = [[NSMutableArray alloc] initWithCapacity:cueArray.count];
        
        [cueArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *cueObjectDict = (NSDictionary *)obj;
            
            Cue *cue = [[Cue alloc] initWithPropertyDictionary:cueObjectDict];
            [cueList addObject:cue];
            [cue release];
            
        }];
        
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

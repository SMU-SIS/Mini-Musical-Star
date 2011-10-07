//
//  Audio.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Audio.h"

@implementation Audio
@synthesize hash, title, path, replaceable, duration, lyrics, audioCueList;

- (id)initWithHash:(NSString *)key dictionary:(NSDictionary *)dictionary assetPath:assetPath
{
    self = [super init];
    if (self) {
        self.hash = key;
        self.title = [dictionary objectForKey:@"title"];
        self.path = [assetPath stringByAppendingPathComponent:[dictionary objectForKey:@"path"]];
        self.replaceable = [dictionary objectForKey:@"replaceable"];
        self.duration = [dictionary objectForKey:@"duration"];
        self.lyrics = [dictionary objectForKey:@"lyrics"];
        
    }
    
    return self;
}

- (void)dealloc
{
    [title release];
    [path release];
    [duration release];
    [lyrics release];
    [audioCueList release];
    [super dealloc];
}

@end

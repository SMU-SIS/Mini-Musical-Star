//
//  Audio.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Audio.h"

@implementation Audio
@synthesize title, path, replaceable, duration, audioCueList;

- (Audio *)initAudioWithPropertyDictionary: (NSDictionary *) pDictionary withPath: (NSString *)showPath
{
    self = [super init];
    if (self) {
        self.title = [pDictionary objectForKey:@"title"];
        self.path = [showPath stringByAppendingString:[pDictionary objectForKey:@"path"]];
        NSLog(@"LOOKIE HERE! path is %@\n", path);
        self.replaceable = [pDictionary objectForKey:@"replaceable"];
        self.duration = [pDictionary objectForKey:@"duration"];
        NSArray *cueArray = [pDictionary objectForKey:@"cues"];
        self.audioCueList = [[NSMutableArray alloc] initWithCapacity:cueArray.count];
        
        [cueArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *cueObjectDict = (NSDictionary *)obj;
            AudioCue *audioCue = [[AudioCue alloc] initAudioCueWithPropertyDictionary:cueObjectDict];
            [audioCueList addObject:audioCue];
            [audioCue release];
        }];
        
    }
    
    return self;
}

- (void)dealloc
{
    [title release];
    [path release];
    [duration release];
    [audioCueList release];
    [super dealloc];
}

@end

//
//  Audio.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Audio.h"
#import "Cue.h"

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
        
        //load in all the cues
        self.audioCueList = [NSMutableDictionary dictionary];
        
        NSDictionary *cuesDict = [dictionary objectForKey:@"cues"];
        
        //this has many cues
        [cuesDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSDictionary *cueDict = (NSDictionary *)obj;
            NSLog(@"cueDict is %@", cueDict);
            
            Cue *aCue = [[Cue alloc] initWithCueHash:key 
                                        startTime:[cueDict objectForKey:@"start-time"] 
                                        endTime:[cueDict objectForKey:@"end-time"]
                                        content:[cueDict objectForKey:@"content"] 
                                        contentPath:[cueDict objectForKey:@"contentPath"]];
            
            NSLog(@"adding cue to audioCueList");
            [self.audioCueList setObject:aCue forKey:key];
            
        }];
        
    }
    
    return self;
}

- (Cue *)cueForSecond: (int)second
{
    __block Cue *cueToReturn = nil;
    NSLog(@"current second is %i", second);
    
    [self.audioCueList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        Cue *aCue = (Cue *)obj;
        NSLog(@"this cue start time is %i and end time is %i", aCue.startTime, aCue.endTime);
        if ((aCue.startTime <= second) && (aCue.endTime) > second)
        {
            cueToReturn = aCue;
            *stop = YES;
        }
    }];
    
    return cueToReturn;
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

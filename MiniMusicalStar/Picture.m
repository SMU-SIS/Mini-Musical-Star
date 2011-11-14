//
//  Picture.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Picture.h"
#import "Cue.h"

@implementation Picture
@synthesize hash, title, image, startTime, duration, pictureCueList, orderNumber, theCue;

- (id)initWithHash:(NSString *)key dictionary:(NSDictionary *)dictionary assetPath:assetPath
{
    self = [super init];
    if (self) {
        self.hash = key;
        self.title = [dictionary objectForKey:@"title"];
        self.image = [[UIImage alloc] initWithContentsOfFile:[assetPath stringByAppendingPathComponent:[dictionary objectForKey:@"path"]]];
        
        //settle the cues
        NSDictionary *cueDict = [dictionary objectForKey:@"cues"];
        [cueDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSDictionary *theCueDict = (NSDictionary *)obj;
            
            NSString *theContent = [theCueDict objectForKey:@"content"];
            NSString *theContentPath = [theCueDict objectForKey:@"content-path"];
            
            self.theCue = [[Cue alloc] initWithCueHash:key startTime:nil endTime:nil content:theContent contentPath:[NSURL fileURLWithPath: theContentPath]];
        }];
    }
    
    return self;
}

- (void)dealloc
{
    [theCue release];
    [title release];
    [image release];
    [pictureCueList release];
    [super dealloc];
}


@end

//
//  Picture.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Picture.h"

@implementation Picture
@synthesize hash, title, image, startTime, duration, pictureCueList, orderNumber;

- (id)initWithHash:(NSString *)key dictionary:(NSDictionary *)dictionary assetPath:assetPath
{
    self = [super init];
    if (self) {
        self.hash = key;
        self.title = [dictionary objectForKey:@"title"];
        self.image = [[UIImage alloc] initWithContentsOfFile:[assetPath stringByAppendingPathComponent:[dictionary objectForKey:@"path"]]];
    }
    
    return self;
}

- (void)dealloc
{
    [title release];
    [image release];
    [pictureCueList release];
    [super dealloc];
}


@end

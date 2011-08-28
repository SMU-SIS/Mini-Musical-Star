//
//  PictureCue.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PictureCue.h"

@implementation PictureCue
@synthesize path, type;

- (PictureCue *)initWithPropertyDictionary: (NSDictionary *) pDictionary
{
    self = [super init];
    if (self) {
        path = [pDictionary objectForKey:@"path"];
        type= [pDictionary objectForKey:@"type"];
    }
    
    return self;
}

- (void)dealloc
{
    [path release];
    [type release];
    [super dealloc];
}


@end

//
//  UndownloadedShow.m
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 14/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UndownloadedShow.h"

@implementation UndownloadedShow
@synthesize showHash, title, downloadURL, coverImage;

-(void)dealloc
{
    [title release];
    [downloadURL release];
    [coverImage release];
    [showHash release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end

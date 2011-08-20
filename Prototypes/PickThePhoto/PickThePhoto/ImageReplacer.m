//
//  ImageReplacer.m
//  PickThePhoto
//
//  Created by Tommi on 20/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageReplacer.h"

@implementation ImageReplacer
@synthesize imagesArray;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithMutableArray:(NSMutableArray*)anImagesArray
{
    self = [super init];
    if (self) {
        //copy the address of the array to imagesArray
        imagesArray = anImagesArray;
    }
    
    return self;
}

- (void)dealloc
{
    imagesArray = nil; //is there a difference between this and [imagesArray release]?
    
    [super dealloc];
}

@end

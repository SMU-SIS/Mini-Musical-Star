//
//  ShowImages.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShowImage.h"


@implementation ShowImage

-(NSArray *)getShowImages
{
    showImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"glee1.jpg"], [UIImage imageNamed:@"glee2.jpg"], [UIImage imageNamed:@"glee3.jpg"], nil];
    
    return [showImages autorelease];
}

@end

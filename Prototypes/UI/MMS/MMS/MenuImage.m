//
//  MenuImage.m
//  MMS
//
//  Created by Weijie Tan on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuImage.h"


@implementation MenuImage

- (NSArray *)getMenuImages
{
    menuImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"glee1.jpg"], [UIImage imageNamed:@"glee2.jpg"], [UIImage imageNamed:@"glee3.jpg"], nil];
    
    return [menuImages autorelease];
}


@end

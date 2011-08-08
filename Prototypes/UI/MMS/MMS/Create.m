//
//  Create.m
//  MMS
//
//  Created by Weijie Tan on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Create.h"


@implementation Create

@synthesize imageNum;

- (IBAction)backToMenu {
    [self dismissModalViewControllerAnimated:YES];    
}

- (void)setImageNum:(int)num 
{
    imageNum=num;
}

- (int) getImageNum
{
    return imageNum;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    menuImages = [MenuImage alloc];
    NSArray *images = [menuImages getMenuImages];
    [menuImages autorelease];
    
    
    UIImage *img = [images objectAtIndex:imageNum];
    
    [imageView setImage:img];
    // Do any additional setup after loading the view from its nib.
}

@end

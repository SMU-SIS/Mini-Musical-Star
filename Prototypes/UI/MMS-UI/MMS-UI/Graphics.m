//
//  Graphics.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Graphics.h"


@implementation Graphics

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    showImage = [ShowImage alloc];
    NSArray *imagesInTheScene = [showImage getImagesInTheScene];
    
    BOOL odd = TRUE;

    for (int i = 0; i<imagesInTheScene.count; i++) {
        UIImage *img = [imagesInTheScene objectAtIndex:i];
        
        int countLeft= 0;
        int countRight = 0;
        
        if (odd == TRUE) {
            CGRect left;
            left.origin.x=scrollView.frame.origin.x + 25;
            left.origin.y=scrollView.frame.origin.y + (countLeft * 150) +25;
            left.size.width = 200;
            left.size.height = 150;
            
            UIButton *button = [[UIButton alloc] initWithFrame:left];
            [button setImage:img forState:(UIControlStateNormal)];
            [button setTag:i+1];
            
            odd = FALSE;
            countLeft++;
            
            [scrollView addSubview:button];
            [button release];
        }
        else {
            CGRect right;
            right.origin.x=scrollView.frame.origin.x + 255;
            right.origin.y=scrollView.frame.origin.y + (countRight *150) +25;
            right.size.width = 200;
            right.size.height = 150;
            
            UIButton *button = [[UIButton alloc] initWithFrame:right];
            [button setImage:img forState:(UIControlStateNormal)];
            [button setTag:i+1];
            
            odd = TRUE; 
            countRight++;
            
            [scrollView addSubview:button];
            [button release];
        }
        
    }
    
    [showImage release];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end

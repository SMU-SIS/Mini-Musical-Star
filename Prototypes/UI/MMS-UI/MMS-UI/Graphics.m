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
        NSLog(@"ARGH is %g", i);
        if (odd == TRUE) {
            CGRect left;
            left.origin.x=scrollView.frame.origin.x + 25;
            left.origin.y=scrollView.frame.origin.y + (i * 100) +25;	
            left.size.width = 200;
            left.size.height = 150;
            
            UIButton *button = [[UIButton alloc] initWithFrame:left];
            [button setImage:img forState:(UIControlStateNormal)];
            button.tag=i;
            NSLog(@"button1 Number is %g", button.tag); 
            NSLog(@"Number1 is %g", i);
            [button addTarget:self action:@selector(setImageToEdit:) forControlEvents:UIControlEventTouchUpInside];
            
            odd = FALSE;
            
            [scrollView addSubview:button];
            [button release];
        }
        else {
            CGRect right;
            right.origin.x=scrollView.frame.origin.x + 255;
            right.origin.y=scrollView.frame.origin.y + ((i-1) * 100) +25;
            right.size.width = 200;
            right.size.height = 150;
            
            UIButton *button = [[UIButton alloc] initWithFrame:right];
            [button setImage:img forState:(UIControlStateNormal)];
            button.tag =i;
            
            NSLog(@"button2 Number is %g", button.tag);
            NSLog(@"Number2 is %g", i);
            [button addTarget:self action:@selector(setImageToEdit:) forControlEvents:UIControlEventTouchUpInside];            
            odd = TRUE; 
            
            [scrollView addSubview:button];
            [button release];
        }
        
    }
    [scrollView setContentSize:CGSizeMake(480, 600 + (imagesInTheScene.count-6)/2 * 175)];
    
    [scrollView setScrollEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setPagingEnabled:YES]; 
    scrollView.clipsToBounds = NO;
    [scrollView setZoomScale:1.5 animated:YES];
    [scrollView setBackgroundColor:[UIColor blackColor]];
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

-(void)setImageToEdit:(id)sender
{    
    NSInteger imgNum = (((UIControl *)sender).tag);
    
    NSLog(@"image2 Number is %g", imgNum);
    
    Edit *edit = [Edit alloc];
    [edit setImageToLeftView:imgNum];
    [edit release];
}

@end

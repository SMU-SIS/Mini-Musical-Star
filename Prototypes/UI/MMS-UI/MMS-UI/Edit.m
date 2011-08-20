//
//  Edit.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Edit.h"
#import "Scene.h"


@implementation Edit

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
    
    //[self setToggleMenu];    
    CGRect rect = CGRectMake(0, 0, toggleView.frame.size.width, toggleView.frame.size.height);
    
    GraphicMenu *graphicMenu = [GraphicMenu alloc];
    UIView *newView = [graphicMenu initWithFrame:rect];
    
    [toggleView addSubview:newView];
    [graphicMenu release];  
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

-(IBAction)setToggleOption
{
    //int selection;
	//election = segControl.selectedSegmentIndex;
    
    if (segControl.selectedSegmentIndex == 0) {
        CGRect rect = CGRectMake(0, 0, toggleView.frame.size.width, toggleView.frame.size.height);
        
        GraphicMenu *graphicMenu = [GraphicMenu alloc];
        UIView *newView = [graphicMenu initWithFrame:rect];
        
        [toggleView addSubview:newView];
        [graphicMenu release];        
    }
    else if (segControl.selectedSegmentIndex == 1) {
        CGRect rect = CGRectMake(0, 0, toggleView.frame.size.width, toggleView.frame.size.height);
        
        AudioMenu *audioMenu = [AudioMenu alloc];
        UIView *newView = [audioMenu initWithFrame:rect];
        
        [toggleView addSubview:newView];
        [audioMenu release];  
    }
    
}

-(IBAction)backToScene
{
    [self dismissModalViewControllerAnimated:YES];  
}

-(UIView *)getGraphics
{
    CGRect rect = CGRectMake(0, 0, toggleView.frame.size.width, toggleView.frame.size.height);
    
    ShowImage *images = [ShowImage alloc];
    NSArray *array = [images getImagesInTheScene];
    
    graphicsMenu = [[UIView alloc] initWithFrame:rect];
    
    CGRect rect2 = CGRectMake(0, 0, 200, 150);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect2];
    
    UIImage *img = [array objectAtIndex:0];
    imgView.image = img;
    
    [graphicsMenu addSubview:imgView];
    [imgView release];
    
    return [graphicsMenu autorelease];
}


@end

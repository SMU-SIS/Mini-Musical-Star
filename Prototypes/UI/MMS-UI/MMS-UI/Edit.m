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
    
    leftView.image = [UIImage imageNamed:@"g1.png"];
    [leftView release];
    
    Graphics *graphicMenu = [Graphics alloc];
    
    [toggleView addSubview:graphicMenu.view];
    //[graphicMenu autorelease]; 
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
    //Decision for Segment Index == 0, which is the Graphics in the scene
    if (segControl.selectedSegmentIndex == 0) {
        
        //Calling out the view controller and add into the toggleView
        Graphics *graphicMenu = [Graphics alloc];
        [toggleView addSubview:graphicMenu.view];
        
        //[graphicMenu release];        
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

-(void)setImageToLeftView:(int)imgNum
{
    leftView.image = [UIImage imageNamed:@"g4.png"];
}


@end

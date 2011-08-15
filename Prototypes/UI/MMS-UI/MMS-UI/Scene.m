//
//  Scene.m
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import "Scene.h"
#import "Edit.h"

@implementation Scene
@synthesize imageNum;

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
    
    menuImages = [ShowImage alloc];
    NSArray *images = [menuImages getShowImages];
    [menuImages autorelease];
    
    
    UIImage *img = [images objectAtIndex:imageNum];
    [sceneButton setBackgroundImage:img forState:UIControlStateNormal];
    
    [imageView setImage:img];    
}

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

-(IBAction)selectScene {
    Edit *editScene = [[Edit alloc] initWithNibName:nil bundle:nil];
    
    editScene.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:editScene animated:YES];
    
    [editScene release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //[imageView1 release];
    //[imageView2 release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

-(void)fromEditToMenu
{
    [self dismissModalViewControllerAnimated:NO];  
}

@end

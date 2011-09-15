//
//  NaviTestViewController.m
//  NaviTest
//
//  Created by Weijie Tan on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NaviTestViewController.h"

@implementation NaviTestViewController

-(IBAction)toScene:(id)sender
{
    Scene *scene = [[Scene alloc] init];
    
    scene.title = @"Scene";
    
    [self.navigationController pushViewController:scene animated:YES];
    
    [scene release];
    
}

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

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    
    [super viewWillAppear:animated];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    [super viewDidLoad];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

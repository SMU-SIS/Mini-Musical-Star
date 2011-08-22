//
//  PlayWithViewsViewController.m
//  PlayWithViews
//
//  Created by Tommi on 20/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayWithViewsViewController.h"

@implementation PlayWithViewsViewController
@synthesize nextView;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/	

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

- (IBAction)ouch:(id)pid;
{
    if (self.nextView == nil) {
        NextView *view2 = [[NextView alloc] initWithNibName:@"View2" bundle:[NSBundle mainBundle]];
        view2.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:view2 animated:YES];
     
        [view2 release];
    }
    
    [self.navigationController pushViewController:self.nextView animated:YES];
}

@end
	
//
//  ProgressOverlayViewController.m
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgressOverlayViewController.h"

@implementation ProgressOverlayViewController

@synthesize progressView;
@synthesize cancelButton;
@synthesize delegate;

-(void) dealloc
{
    [delegate release];
    [progressView release];
    [cancelButton release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

-(IBAction)cancelProgressView:(id)sender
{
    [delegate cancelExportSession];
    [self.view removeFromSuperview];
}

-(void) changeCancelToDoneButton
{
    [self.cancelButton setTitle:@"Done" forState:UIControlStateNormal];
}


@end

//
//  Playback.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaybackViewController.h"

@implementation PlaybackViewController
@synthesize theShow, theScene, playbackView, player;

- (PlaybackViewController *)initWithShow:(Show *)aShow
{
    [super init];
    self.theShow = aShow;
    
    self.theScene = [theShow.scenes objectAtIndex:0];
    
    
    return self;
    
}

- (void)dealloc
{
    [player release];
    [theScene release];
    [theShow release];
    [playbackView release];
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
    self.player = [[ScenePlayer alloc] initWithScene:theScene andView:self.playbackView];
    [player startPlayback];
    
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

- (IBAction)backToMenu {
    [self dismissModalViewControllerAnimated:YES];    
}

@end

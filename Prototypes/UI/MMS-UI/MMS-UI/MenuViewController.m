//
//  MMS_UIViewController.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController
@synthesize shows;

- (void)dealloc
{
    [shows release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadShows
{
    //load the shows on the local disk
    [ShowDAO loadLocalShows];
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load the shows on the local disk
    [ShowDAO loadLocalShows];
    self.shows = [ShowDAO shows];
    
//    NSLog(@"shows are %@\n", shows);
    

    //return the array of show images; reason being, i need to get the scrollview content size based on the image count.
    //showImages = [ShowImage alloc];
    //NSArray *images = showImages.getShowImages; 
    
    NSArray *images = [ShowDAO imagesForShows];
    
    //display the show images.
    [self displayShowImages:images];
    
    //setting the scrollview attributes
    [scrollView setScrollEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setPagingEnabled:YES]; 
    scrollView.clipsToBounds = NO;    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width + (images.count+1)* 280, scrollView.frame.size.height)];
    
    [showImages release];
    
    
    //set up the hidden frame to scroll the scrollView outside from outside it's rectangle
    CGRect hiddenScrollViewFrame = CGRectMake(0, 174, 1024, scrollView.frame.size.height); //make a CGRect for HiddenView
    HiddenView *hiddenView = [[[HiddenView alloc] initWithFrame:hiddenScrollViewFrame] autorelease]; //init new HiddenView which is a custom UIView
    hiddenView.menuScrollView = scrollView;
    [self.view addSubview:hiddenView]; //add to the MenuViewController
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

//Button action for creating new musical
- (IBAction)createMusical {
//    SceneViewController *sceneView = [[SceneViewController alloc] initWithNibName:nil bundle:nil];
    
    int current = [self currentPage]; 

    int currentSelection = [self currentPage];
    SceneViewController *sceneView = [[SceneViewController alloc] initWithScenesFromShow:[shows objectAtIndex:currentSelection]];
        [sceneView setImageNum:current];
        
        sceneView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:sceneView animated:YES];
        
        [sceneView release];
}

-(int)currentPage
{
	// Calculate which page is visible 
	CGFloat pageWidth = scrollView.frame.size.width;
	int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
	return page;
}

- (IBAction)playBackMusical {
    PlaybackViewController *pBackMusical = [[PlaybackViewController alloc] initWithNibName:nil bundle:nil];
    
    int current = [self currentPage];    
    [pBackMusical setImageNum:current];
    
    pBackMusical.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:pBackMusical animated:YES];
    
    [pBackMusical release];
}

- (IBAction)coverMusical {
    CoverViewController *covers = [[CoverViewController alloc] initWithNibName:nil bundle:nil];
    
    int current = [self currentPage];    
    [covers setImageNum:current];
    
    covers.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:covers animated:YES];
    
    [covers release];
}

-(void)displayShowImages:(NSArray *)images
{
    for (int i=0; i<images.count; i++) {
        CGRect frame;
        frame.origin.x = scrollView.frame.size.width * i + 10;
        frame.origin.y = 0;
        frame.size.width = 280;
        frame.size.height = scrollView.frame.size.height;
        
        NSLog(@"Width is %g", scrollView.frame.size.width *i+320);
        NSLog(@"Length is %g", frame.size.height);
        
        UIImage *img = [images objectAtIndex:i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = img;
        
        [scrollView addSubview:imageView];
        [imageView release];
    }
}

@end

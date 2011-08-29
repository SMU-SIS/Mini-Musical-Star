//
//  MMS_UIViewController.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MMS_UIViewController.h"


@implementation MMS_UIViewController
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load the shows on the local disk
    [ShowDAO loadLocalShows];
    self.shows = [ShowDAO shows];
    
    NSLog(@"shows are %@\n", shows);
    
    [scrollView setScrollEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setPagingEnabled:YES]; 
    scrollView.clipsToBounds = NO;
    [scrollView setZoomScale:1.5 animated:YES];
   // CGFloat contentOffset = 0.0f;
    
    /* HARD CODED
    showImages = [ShowImage alloc];
    NSArray *images = [showImages getShowImages];    
    */
    
    //add the images of the shows to an array to display to user
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:shows.count];
    [shows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Show *show = (Show *)obj;
        NSLog(@"ASDASD %@",show.title);
        [images addObject:show.coverPicture];
    }];
    
    //Jun Kit: Wei Jie, I replaced your for loop with a block
    [images enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
        CGRect frame;
        frame.origin.x = scrollView.frame.size.width * i + 10;
        frame.origin.y = 0;
        //frame.size = scrollView.frame.size;
        frame.size.width = 280;
        frame.size.height = scrollView.frame.size.height;
        //CGRect imageViewFrame = CGRectMake(contentOffset, 0.0f, scrollView.frame.size.width-600, scrollView.frame.size.height);
        NSLog(@"Width is %g", scrollView.frame.size.width *i+320);
        NSLog(@"Length is %g", frame.size.height);
        
        UIImage *img = (UIImage *)obj;
        
        //resizing the image
        /*
         UIGraphicsBeginImageContext(img.size);
         [img drawInRect:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
         UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
         */
        
        
        //creating an ImageView and insert into scrollView as a subview
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = img;
        
        /*
         UIView *subview = [[UIView alloc] initWithFrame:frame];
         
         //subview.backgroundColor = [colors objectAtIndex:i];
         //subview.backgroundColor = [[UIColor alloc] initWithPatternImage:newImage];
         [subview center];
         */
        
        //contentOffset += imageView.frame.size.width;
		//scrollView.contentSize = CGSizeMake(contentOffset, scrollView.frame.size.height);
        [scrollView addSubview:imageView];
        [imageView release];
    }];
    
   [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width + images.count* 280, scrollView.frame.size.height)];
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
//    SceneUI *sceneView = [[SceneUI alloc] initWithNibName:nil bundle:nil];
//    
//    //find out which musical is currently selected
//    int current = [self currentPage];    
//    [sceneView setImageNum:current];
//    
//    sceneView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentModalViewController:sceneView animated:YES];
//    
//    [sceneView release];

    //find out which show is currently selected
    int currentSelection = [self currentPage];
    Show *show = [shows objectAtIndex:currentSelection];
    NSLog(@"shows woooo: %@",show.scenes);
    SceneUI *sceneView = [[SceneUI alloc] initWithScenesFromShow:[shows objectAtIndex:currentSelection]];
    NSLog(@"THE NUMBER IS %i",[self currentPage]);
    
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
    Playback *pBackMusical = [[Playback alloc] initWithNibName:nil bundle:nil];
    
    int current = [self currentPage];    
    [pBackMusical setImageNum:current];
    
    pBackMusical.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:pBackMusical animated:YES];
    
    [pBackMusical release];
}

- (IBAction)coverMusical {
    Cover *covers = [[Cover alloc] initWithNibName:nil bundle:nil];
    
    int current = [self currentPage];    
    [covers setImageNum:current];
    
    covers.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:covers animated:YES];
    
    [covers release];
}

@end

//
//  MMS_UIViewController.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MMS_UIViewController.h"
#import "Edit.h"
#import "Scene.h"
#import "Playback.h"
#import "Cover.h"

@implementation MMS_UIViewController

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [scrollView setScrollEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setPagingEnabled:YES]; 
    scrollView.clipsToBounds = NO;
    [scrollView setZoomScale:1.5 animated:YES];
    
    showImages = [ShowImage alloc];
    NSArray *images = [showImages getShowImages];    
    
    for (int i=0; i<images.count; i++) {
        CGRect frame;
        frame.origin.x = 320+i*300;
        frame.origin.y = 0;
        //frame.size = scrollView.frame.size;
        frame.size.width = 280;
        frame.size.height = scrollView.frame.size.height;
        
        NSLog(@"Width is %g", scrollView.frame.size.width *i+320);
        NSLog(@"Length is %g", frame.size.height);
        
        UIImage *img = [images objectAtIndex:i];
        
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
        
        [scrollView addSubview:imageView];
        [imageView release];
        
    }
    
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
    Scene *sceneView = [[Scene alloc] initWithNibName:nil bundle:nil];
    
    int current = [self currentPage];    
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

//
//  MMS_UIViewController.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController
@synthesize shows, fetchedResultsController, managedObjectContext;


- (void)dealloc
{
    [shows release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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
    [ShowDAO loadShowsWithDelegate:self];
    
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Downloading Shows..."];
}

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    scrollView.hidden = NO;
}

- (void)daoDownloadQueueFinished
{
    self.shows = [ShowDAO shows];
    [DSBezelActivityView removeViewAnimated:YES];
    
    //continue setting up the scrollview
    
    //return the array of show images; reason being, i need to get the scrollview content size based on the image count.
    NSArray *images = [ShowDAO imagesForShows];
    //display the show images.
    [self displayShowImages:images];
    
    //setting the scrollview attributes
    [scrollView setScrollEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setPagingEnabled:NO]; 
    scrollView.clipsToBounds = NO;    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width + (images.count+1)* 280, scrollView.frame.size.height)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


//Button action for creating new musical
- (IBAction)createMusical: (UIButton*)sender {
    
    Cover *newCover = [NSEntityDescription insertNewObjectForEntityForName:@"Cover" inManagedObjectContext:managedObjectContext];
    newCover.cover_of_showID = [NSNumber numberWithInt:[[shows objectAtIndex:sender.tag] showID]];
    SceneViewController *sceneView = [[SceneViewController alloc] initWithScenesFromShow:[shows objectAtIndex:sender.tag] andCover:newCover andContext:managedObjectContext];
    sceneView.title = [[shows objectAtIndex:sender.tag] title];
    
    [self.navigationController pushViewController:sceneView animated:YES];
    
        
    [sceneView release];
}

-(Show *)returnCurrentSelectedShow:(id) sender
{
	// Calculate which page is visible 
	
    for (int i=0; i<[buttonArray count];i++){
        if([sender isEqual: [buttonArray objectAtIndex:i]]){
            return [shows objectAtIndex:i];
        };
    }
	return nil;
}

-(void)displayShowImages:(NSArray *)images
{
    for (int i=0; i<images.count; i++) {
        CGRect frame;
        frame.origin.x = scrollView.frame.size.width/3 * i;
        frame.origin.y = 0;
        frame.size.width = 280;
        frame.size.height = scrollView.frame.size.height;
        
        UIImage *img = [images objectAtIndex:i];
        
        UIButton *imageView = [[UIButton alloc] initWithFrame:frame];
        imageView.layer.cornerRadius = 10; // this value vary as per your desire
        imageView.clipsToBounds = YES;
        
        [imageView setImage:img forState:UIControlStateNormal];
        
        imageView.tag = i;
        
        [imageView addTarget:self action:@selector(createMusical:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonArray addObject: imageView];
        
        [scrollView addSubview:imageView];
        [imageView release];
    }
}

@end

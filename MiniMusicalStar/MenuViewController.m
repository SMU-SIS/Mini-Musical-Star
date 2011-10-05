//
//  MMS_UIViewController.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController
@synthesize shows, fetchedResultsController, managedObjectContext, currentSelectedMusical, currentSelectedCoversList;


- (void)dealloc
{
    [shows release];
    [currentSelectedCoversList release];
    [currentSelectedMusical release];
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
    newCover.cover_of_showID = [NSNumber numberWithInt:[[shows objectAtIndex:currentSelectedMusical.tag] showID]];
    SceneViewController *sceneView = [[SceneViewController alloc] initWithScenesFromShow:[shows objectAtIndex:currentSelectedMusical.tag] andCover:newCover andContext:managedObjectContext];
    sceneView.title = [[shows objectAtIndex:currentSelectedMusical.tag] title];
    
    [self.navigationController pushViewController:sceneView animated:NO];
        
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
        
        //add the placeholder view...
        UIView *musicalButtonView = [[UIView alloc] initWithFrame:frame];
        [scrollView addSubview:musicalButtonView];
        
        //add the musical image as a button...
        CGRect buttonFrame;
        buttonFrame.origin.x = 0;
        buttonFrame.origin.y = 0;
        buttonFrame.size.width = 280;
        buttonFrame.size.height = frame.size.height;
        
        UIButton *imageView = [[UIButton alloc] initWithFrame:buttonFrame];
        imageView.layer.cornerRadius = 10; // this value vary as per your desire
        imageView.clipsToBounds = YES;
        imageView.adjustsImageWhenHighlighted = NO;
        
        [imageView setImage:[images objectAtIndex:i] forState:UIControlStateNormal];
        imageView.tag = i;
        [imageView addTarget:self action:@selector(showTranslucentViewsForMusicalButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self applyTransparencyToImageView:imageView];
        
        [buttonArray addObject: imageView];
        [musicalButtonView addSubview: imageView];
        
        [imageView release];
    }
}

-(void)applyTransparencyToImageView:(UIImageView *)musicalButton
{
    //the top part
    CGRect topFrame;
    topFrame.origin.x = 0;
    topFrame.origin.y = 0;
    topFrame.size.width = 280;
    topFrame.size.height = 40;
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:topFrame];
    topLabel.text = @"3 Covers";
    topLabel.textColor = [UIColor whiteColor];
    topLabel.backgroundColor = [UIColor darkGrayColor];
    topLabel.textAlignment = UITextAlignmentCenter;
    topLabel.tag = -1; //to indiciate it's the translucent view
    
    topLabel.layer.opacity = 0.8;
    topLabel.hidden = YES;
    
    UIButton *listCoversButton = [[UIButton alloc] initWithFrame:topFrame];
    [listCoversButton addTarget:self action:@selector(listCoversForMusical:) forControlEvents:UIControlEventTouchUpInside];
    listCoversButton.enabled = NO;
    
    [musicalButton addSubview:listCoversButton];
    [musicalButton addSubview:topLabel];
    [listCoversButton release];
    
    //the bottom part
    CGRect bottomFrame;
    bottomFrame.origin.x = 0;
    bottomFrame.origin.y = musicalButton.frame.size.height - 40;
    bottomFrame.size.width = 280;
    bottomFrame.size.height = 40;
    
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:bottomFrame];
    bottomLabel.text = @"Create new cover";
    bottomLabel.textColor = [UIColor whiteColor];
    bottomLabel.backgroundColor = [UIColor darkGrayColor];
    bottomLabel.textAlignment = UITextAlignmentCenter;
    bottomLabel.tag = -1; //to indiciate it's the translucent view
    
    UIButton *createMusicalButton = [[UIButton alloc] initWithFrame:bottomFrame];
    [createMusicalButton addTarget:self action:@selector(createMusical:) forControlEvents:UIControlEventTouchUpInside];
    createMusicalButton.enabled = NO;
    
    bottomLabel.layer.opacity = 0.8;
    bottomLabel.hidden = YES;
    
    [musicalButton addSubview:bottomLabel];
    [musicalButton addSubview:createMusicalButton];
    [createMusicalButton release];
    
}

-(void)showTranslucentViewsForMusicalButton:(UIImageView *)musicalButton
{
    
    
    // First create a CATransition object to describe the transition
	CATransition *transition = [CATransition animation];
	// Animate over 1/4 of a second
	transition.duration = 0.25;
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;

    
    CATransition *theAnimation = [CATransition animation];
    theAnimation.duration=1.0;
    
    //hide subviews of last selected button
    if (self.currentSelectedMusical != nil)
    {
        [self.currentSelectedMusical.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *subview = (UIView *)obj;
            if ([subview isKindOfClass:[UIButton class]])
            {
                UIButton *theButton = (UIButton *)subview;
                theButton.enabled = NO;
            }
            
            if (subview.tag == -1)
            {
                [subview.layer addAnimation:transition forKey:nil];
                subview.hidden = YES;
            }
            
            
        }];
    }
    
    [musicalButton.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *subview = (UIView *)obj;
        if ([subview isKindOfClass:[UIButton class]])
        {
            UIButton *theButton = (UIButton *)subview;
            theButton.enabled = YES;
        }
        
        if (subview.tag == -1)
        {
            [subview.layer addAnimation:transition forKey:nil];
            subview.hidden = NO;
        }
    }];
    
    self.currentSelectedMusical = musicalButton;
}

- (void)listCoversForMusical:(id)sender
{
    UIView *parentView = self.currentSelectedMusical.superview;
    
    CGRect coversFrame;
    coversFrame.origin.x = 0;
    coversFrame.origin.y = 0;
    coversFrame.size.width = 280;
    coversFrame.size.height = parentView.frame.size.height;
    
    CoversListViewController *coversView = [[CoversListViewController alloc] initWithShow:[shows objectAtIndex:currentSelectedMusical.tag] context:self.managedObjectContext];
    coversView.view.frame = coversFrame;
    coversView.delegate = self;
    
    UINavigationController *coversListNavController = [[UINavigationController alloc] initWithRootViewController:coversView];
    coversListNavController.view.frame = coversFrame;
    self.currentSelectedCoversList = coversListNavController;
    
    [self.currentSelectedMusical removeFromSuperview];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:parentView cache:YES];
    [UIView setAnimationDuration:1.0];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
    parentView.transform = transform;
    [UIView commitAnimations];
    
    [parentView addSubview:coversListNavController.view];
    
}

- (void)flipCoversBackToFront
{
    UIView *parentView = self.currentSelectedMusical.superview;
    
    [self.currentSelectedCoversList.view removeFromSuperview];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:parentView cache:YES];
    [UIView setAnimationDuration:1.0];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
    parentView.transform = transform;
    [UIView commitAnimations];
    
    [parentView addSubview:self.currentSelectedMusical];
    self.currentSelectedCoversList = nil;
}

@end

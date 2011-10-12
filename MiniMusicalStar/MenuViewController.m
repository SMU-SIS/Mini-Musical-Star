//
//  MMS_UIViewController.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"
#import "NewOpenViewController.h"

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
    [scrollView setContentSize:CGSizeMake((images.count)* 280, scrollView.frame.size.height)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


//Button action for creating new musical
- (IBAction)musicalButtonWasPressed: (UIButton*)sender 
{
    
    Show *selectedShow = [shows objectAtIndex:sender.tag];
    NewOpenViewController *newOpen = [[NewOpenViewController alloc] initWithShow:selectedShow context:self.managedObjectContext];
    
    [self.navigationController pushViewController:newOpen animated:YES];
        
    [selectedShow release];
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
        //[imageView addTarget:self action:@selector(musicalButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        //[imageView addTarget:self action:@selector(showTranslucentViewsForMusicalButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [imageView addTarget:self action:@selector(selectMusical:) forControlEvents:UIControlEventTouchUpInside];
        
        //[self performSelector:@selector(applyTransparencyToImageView:) withObject:imageView];

        
        [buttonArray addObject: imageView];
        [musicalButtonView addSubview: imageView];
        
        [imageView release];
    }
}



//weijie test method
-(void)selectMusical:(UIImageView *)musicalButton
{
    self.currentSelectedMusical = musicalButton;

    
    ChoiceSelectionViewController *choiceView = [[ChoiceSelectionViewController alloc] initWithAShowForSelection:[shows objectAtIndex:currentSelectedMusical.tag] context:self.managedObjectContext];
    
    
    choiceView.title = [[shows objectAtIndex:currentSelectedMusical.tag] title];
    
    [self.navigationController pushViewController:choiceView animated:YES];
    
    [choiceView release];
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






@end

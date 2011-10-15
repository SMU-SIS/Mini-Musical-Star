//
//  MMS_UIViewController.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"
#import "NewOpenViewController.h"
#import "UndownloadedShow.h"
#import "ShowDAO.h"
#import "Show.h"
#import "Cover.h"
#import "ChoiceSelectionViewController.h"
#import "DSActivityView.h"

@implementation MenuViewController
@synthesize managedObjectContext, scrollView, buttonArray, showDAO;


- (void)dealloc
{
    [managedObjectContext release];
    [scrollView release];
    [buttonArray release];
    [ShowDAO release];
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
    self.showDAO = [[ShowDAO alloc] initWithDelegate:self];
    
    [self createScrollViewOfShows];
    [self.showDAO addObserver:self forKeyPath:@"loadedShows" options:NSKeyValueObservingOptionNew context:@"NewShowDownloaded"];

}

- (void)createScrollViewOfShows
{
    //let's start by setting the scrollview attributes
    scrollView.scrollEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = NO;
    scrollView.clipsToBounds = NO;    
    [scrollView setContentSize:CGSizeMake(self.showDAO.loadedShows.count * 280, scrollView.frame.size.height)];
    
    //self.shows contains both downloaded and undownloaded shows, make sure to differentiate
    [self.showDAO.loadedShows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CGRect frame;
        frame.origin.x = scrollView.frame.size.width/3 * idx;
        frame.origin.y = 0;
        frame.size.width = 280;
        frame.size.height = scrollView.frame.size.height;
        
        //add the placeholder view...
        UIView *musicalButtonView = [[UIView alloc] initWithFrame:frame];
        [scrollView addSubview:musicalButtonView];
        
        //add the cover image as a button...
        CGRect buttonFrame;
        buttonFrame.origin.x = 0;
        buttonFrame.origin.y = 0;
        buttonFrame.size.width = 280;
        buttonFrame.size.height = frame.size.height;
        
        UIButton *showButton;
        
        //now we check if it's downloaded or undownloaded
        if ([obj isKindOfClass:[Show class]])
        {
            showButton = [self createButtonForShow:(Show *)obj frame:buttonFrame];
        }
        
        else if ([obj isKindOfClass:[UndownloadedShow class]])
        {
            showButton = [self createButtonForUndownloadedShow:(UndownloadedShow *)obj frame:buttonFrame];
        }
        
        showButton.tag = idx;
        [buttonArray addObject: showButton];
        [musicalButtonView addSubview: showButton];
    }];
    
    
}

- (UIButton *)createButtonForShow:(Show *)aShow frame:(CGRect)buttonFrame
{
    UIButton *showButton = [[UIButton alloc] initWithFrame:buttonFrame];
    showButton.layer.cornerRadius = 10; // this value vary as per your desire
    showButton.clipsToBounds = YES;
    showButton.adjustsImageWhenHighlighted = NO;
    
    [showButton setImage:aShow.coverPicture forState:UIControlStateNormal];
    [showButton addTarget:self action:@selector(selectMusical:) forControlEvents:UIControlEventTouchUpInside];
    
    return [showButton autorelease];
    
}

- (UIButton *)createButtonForUndownloadedShow:(UndownloadedShow *)aShow frame:(CGRect)buttonFrame
{
    UIButton *showButton = [[UIButton alloc] initWithFrame:buttonFrame];
    showButton.layer.cornerRadius = 10; // this value vary as per your desire
    showButton.clipsToBounds = YES;
    showButton.adjustsImageWhenHighlighted = NO;
    
    [showButton.layer setOpacity:0.6]; //make the undownloaded musical lighter
    
    [showButton setImage:aShow.coverImage forState:UIControlStateNormal];
    [showButton addTarget:self action:@selector(downloadMusical:) forControlEvents:UIControlEventTouchUpInside];
    
    return [showButton autorelease];
    
}

- (void)downloadMusical:(UIButton *)sender
{
    //create a progress indicator
    CGRect progressBarFrame;
    progressBarFrame.size.width = 250;
    progressBarFrame.size.height = 10;
    progressBarFrame.origin.x = 10;
    progressBarFrame.origin.y = sender.frame.size.height - 20;
    
    UIProgressView *progressBar = [[UIProgressView alloc] initWithFrame:progressBarFrame];
    [sender addSubview:progressBar];
    
    [self.showDAO downloadShow:[self.showDAO.loadedShows objectAtIndex:sender.tag] progressIndicatorDelegate:progressBar];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //cast the context as a string
    NSString *contextString = (NSString *)context;
    if ([contextString isEqualToString:@"NewShowDownloaded"])
    {
        //find out what is the index of the show
        NSIndexSet *changedObjects = [change objectForKey:NSKeyValueChangeIndexesKey];
        int indexOfShow = [changedObjects firstIndex];
        if (indexOfShow < 0) NSLog(@"Error: Cannot find index of new show");
        else
        {
            //up the button opacity and change the button target
            UIButton *theButton = [buttonArray objectAtIndex:indexOfShow];
            theButton.layer.opacity = 1.0;
            [theButton removeTarget:self action:@selector(downloadMusical:) forControlEvents:UIControlEventTouchUpInside];
            [theButton addTarget:self action:@selector(selectMusical:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    scrollView.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    scrollView.hidden = NO;
}

- (void)viewDidUnload
{
    [self.showDAO removeObserver:self forKeyPath:@"loadedShows"];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//weijie test method
-(void)selectMusical:(UIImageView *)musicalButton
{
    
    Show *theShow = [self.showDAO.loadedShows objectAtIndex:musicalButton.tag];
    
    ChoiceSelectionViewController *choiceView = [[ChoiceSelectionViewController alloc] initWithAShowForSelection: theShow context:self.managedObjectContext];
    
    
    choiceView.title = theShow.title;
    [self.navigationController pushViewController:choiceView animated:YES];
    [choiceView release];
}

@end

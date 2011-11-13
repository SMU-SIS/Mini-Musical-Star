//
//  ExportViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ExportViewController.h"

@implementation ExportViewController

@synthesize theShow, theCover, context;
@synthesize exportTableViewController;
@synthesize mediaTableViewController;
@synthesize facebookUploaderViewController;
@synthesize youtubeUploaderViewController;
@synthesize addCreditsButton;
@synthesize popoverController;
@synthesize addCreditsViewController;
@synthesize progressViewController;
@synthesize tutorialButton;
    
- (void)dealloc
{
    [tutorialButton release];
    [theShow release];
    [theCover release];
    [context release];
    
    [progressViewController release];
    [popoverController release];
    [mediaTableViewController release];
    [exportTableViewController release];
    [addCreditsViewController release];
    
    [youtubeUploaderViewController release];
    [facebookUploaderViewController release];
    
    [addCreditsButton release];
    [super dealloc];
}

- (NSMutableArray*) getTextFieldArray
{
    return [addCreditsViewController getTextFieldArray];
}

- (ExportViewController*)initWithStuff:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self) {
        self.theShow = show;
        self.theCover = cover;
        self.context = aContext;
        
        self.addCreditsViewController = [[AddCreditsViewController alloc] init];
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.addCreditsViewController];
        [self.popoverController setPopoverContentSize:CGSizeMake(400,300)];
        
        self.exportTableViewController = [[ExportTableViewController alloc] initWithStyle:UITableViewStyleGrouped :theShow :theCover context:context];
        [self.exportTableViewController setDelegate:self];
        
        self.mediaTableViewController = [[MediaTableViewController alloc] initWithStyle:UITableViewStyleGrouped withCover:self.theCover withContext:context];
        [self.mediaTableViewController setDelegate:self];
        
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"exportpage.png"]];
        self.view.backgroundColor = background;
        
        self.exportTableViewController.tableView.backgroundView.hidden = YES;
        self.exportTableViewController.tableView.frame = CGRectMake(50,160,400,590);
        
        [self.exportTableViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        self.mediaTableViewController.tableView.frame = CGRectMake(570,160,370,590);
        self.mediaTableViewController.tableView.backgroundView.hidden = YES;
        
        [self.mediaTableViewController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        self.progressViewController = [[ProgressOverlayViewController alloc] init];
        [self.progressViewController setDelegate:self];
        
        [self.view addSubview:self.exportTableViewController.tableView];
        [self.view addSubview:self.mediaTableViewController.tableView];
    }
    
    return self;
}

- (void) showProgressView
{
    [self.progressViewController.view setAlpha:0.0];
    [self.view addSubview:progressViewController.view];
    [UIView beginAnimations:nil context:nil];
    [self.progressViewController.view setAlpha:1.0];
    [UIView commitAnimations];
}

- (void) setProgressViewAtValue:(float)value withAnimation:(BOOL)isAnimated
{
    [progressViewController.progressView setProgress:value animated:isAnimated];
    if(value == 1.0){
        [self performSelector:@selector(removeProgressView) withObject:nil afterDelay:5.0];
    }
}

- (void) removeProgressView
{
    [progressViewController.view removeFromSuperview];
}

-(void) cancelExportSession
{
    [self.exportTableViewController cancelExportSession];
}

- (IBAction) editTable:(id)sender
{
    if (self.mediaTableViewController.tableView.editing == YES)
    {
        [self.mediaTableViewController.tableView setEditing:NO animated:YES];
        
    }
    
    else
    {
        [self.mediaTableViewController.tableView setEditing:YES animated:YES];
    }
}
- (IBAction) togglePopoverForAddCredits
{
    [self.popoverController presentPopoverFromRect:self.addCreditsButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void) reloadMediaTable
{
    [self.mediaTableViewController populateTable];
    [self.mediaTableViewController.tableView reloadData];
}

- (void) playMovie:(NSURL*)filePath
{
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: filePath];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(moviePlayBackDidFinish:)
                                                name:MPMoviePlayerPlaybackDidFinishNotification
                                              object:moviePlayer];
    [moviePlayer setFullscreen:YES animated:YES];
    self.navigationController.navigationBarHidden = YES;
    moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    moviePlayer.shouldAutoplay = YES;
    [moviePlayer.view setFrame: self.view.bounds];  // player's frame must match parent's
    
    [self.view addSubview: moviePlayer.view];

    [moviePlayer play];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *moviePlayer = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer];
    
    // If the moviePlayer.view was added to the view, it needs to be removed
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)]) {
        [moviePlayer.view removeFromSuperview];
    }
    self.navigationController.navigationBarHidden = NO;
    
    [moviePlayer release];
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

}

- (void)viewWillAppear:(BOOL)animated
{
    //create custom back button
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    [backBarButtonItem release];
}

-(IBAction)back {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: 0.75];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:YES];
    
    [[self navigationController] popViewControllerAnimated:NO];
    
    [UIView commitAnimations];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



#pragma - FacebookUploaderDelegate methods

- (void)removeFacebookUploadOverlay
{
    [UIView beginAnimations:nil context:nil];
    [facebookUploaderViewController.view setAlpha:0.0];
    [UIView commitAnimations];
//    [self.facebookUploaderViewController.view removeFromSuperview];

    [self.facebookUploaderViewController release];
}

#pragma - YouTubeUploaderDelegate methods

- (void)removeYouTubeUploadOverlay
{
    if (youtubeUploaderViewController.isUploading) {
        [youtubeUploaderViewController cancelUpload];
    }
    
    [UIView beginAnimations:nil context:nil];
    [youtubeUploaderViewController.view setAlpha:0.0];
    [UIView commitAnimations];
    
//    [self.youtubeUploaderViewController.view removeFromSuperview];
    [self.youtubeUploaderViewController release];
}

#pragma - MediaTableViewDelegate methods

- (void)uploadToFacebook:(NSURL *)filePath
{
    
    facebookUploaderViewController = [[FacebookUploaderViewController alloc] initWithProperties:filePath title:@"Uploaded with Mini Musical Star" description:@""];
    
    self.facebookUploaderViewController.delegate = self;
    [facebookUploaderViewController.view setAlpha:0.0];
    [self.view addSubview:facebookUploaderViewController.view];
    [UIView beginAnimations:nil context:nil];
    [facebookUploaderViewController.view setAlpha:0.9];
    [UIView commitAnimations];
}

- (void) uploadToYouTube:(NSURL*)filePath
{
    youtubeUploaderViewController = [[YouTubeUploaderViewController alloc] initWithProperties:filePath title:@"Uploaded with Mini Musical Star" description:@"Uploaded with Mini Musical Star"];

    self.youtubeUploaderViewController.delegate = self;
    [self.view addSubview:youtubeUploaderViewController.view];
    [UIView beginAnimations:nil context:nil];
    [youtubeUploaderViewController.view setAlpha:0.9];
    [UIView commitAnimations];
}

- (IBAction) playTutorial:(id)sender
{
    //play tutorial video player
    [self playMovie:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mov"]]];
}

@end

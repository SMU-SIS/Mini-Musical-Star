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
    
- (void)dealloc
{
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
        
        self.mediaTableViewController.tableView.frame = CGRectMake(570,160,370,590);
        self.mediaTableViewController.tableView.backgroundView.hidden = YES;
        
        self.progressViewController = [[ProgressOverlayViewController alloc] init];
        [self.progressViewController setDelegate:self];
        
        [self.view addSubview:self.exportTableViewController.tableView];
        [self.view addSubview:self.mediaTableViewController.tableView];
    }
    
    return self;
}

- (void) showProgressView
{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.75];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:progressViewController.view cache:YES];
    [progressViewController.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.view addSubview:progressViewController.view];
//    [UIView commitAnimations];
}

- (void) setProgressViewAtValue:(float)value withAnimation:(BOOL)isAnimated
{
    [progressViewController.progressView setProgress:value animated:isAnimated];
    if(value == 1.0){
        [progressViewController changeCancelToDoneButton];
    }
}

- (void) removeProgressView:(float)value withAnimation:(BOOL)isAnimated
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
    [self.popoverController presentPopoverFromRect:CGRectMake(211,74,110,37) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
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

- (void)facebookUploadSuccess
{  
    [self.facebookUploaderViewController.view removeFromSuperview];
    [self.facebookUploaderViewController release];
}

- (void)facebookUploadNotSuccessful
{   
    [self.facebookUploaderViewController.view removeFromSuperview];
    [self.facebookUploaderViewController release];
}

#pragma - YouTubeUploaderDelegate methods

- (void)youTubeUploadSuccess
{
    NSLog(@"uploadSuccess");
    [self.youtubeUploaderViewController.view removeFromSuperview];
    [self.youtubeUploaderViewController release];
}

- (void)youTubeUploadFailed
{
    
}

#pragma - MediaTableViewDelegate methods

- (void)uploadToFacebook:(NSURL *)filePath
{
    
    facebookUploaderViewController = [[FacebookUploaderViewController alloc] initWithProperties:filePath title:@"Uploaded with Mini Musical Star" description:@""];
    
    self.facebookUploaderViewController.delegate = self;
    [self.view addSubview:facebookUploaderViewController.view];
    facebookUploaderViewController.view.alpha = 0.9;
    facebookUploaderViewController.centerView.alpha = 1;
    facebookUploaderViewController.centerView.backgroundColor = [UIColor whiteColor];
    
    [facebookUploaderViewController startUpload];
}

- (void) uploadToYouTube:(NSURL*)filePath
{
    youtubeUploaderViewController = [[YouTubeUploaderViewController alloc] initWithProperties:filePath title:@"Uploaded with Mini Musical Star" description:@"Uploaded with Mini Musical Star"];

    self.youtubeUploaderViewController.delegate = self;
    [self.view addSubview:youtubeUploaderViewController.view];
    youtubeUploaderViewController.view.alpha = 0.9;
    youtubeUploaderViewController.centerView.alpha = 1;
    youtubeUploaderViewController.centerView.backgroundColor = [UIColor whiteColor];
    
    [youtubeUploaderViewController startUpload];
}

@end

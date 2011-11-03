//
//  ExportViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ExportViewController.h"
#import "AddCreditsViewController.h"

@implementation ExportViewController

@synthesize theShow, theCover, context;
@synthesize exportTableViewController;
@synthesize mediaTableViewController;
@synthesize facebookUploaderViewController;
@synthesize youtubeUploaderViewController;
@synthesize addCreditsButton;
    
- (void)dealloc
{
    [theShow release];
    [theCover release];
    [context release];
    
    [mediaTableViewController release];
    [exportTableViewController release];
    
    [youtubeUploaderViewController release];
    [facebookUploaderViewController release];
    
    [addCreditsButton release];
    [super dealloc];
}

- (ExportViewController*)initWithStuff:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self) {
        self.theShow = show;
        self.theCover = cover;
        self.context = aContext;
        
        self.exportTableViewController = [[ExportTableViewController alloc] initWithStyle:UITableViewStyleGrouped :theShow :theCover context:context];
        [self.exportTableViewController setDelegate:self];
        
        self.mediaTableViewController = [[MediaTableViewController alloc] initWithStyle:UITableViewStyleGrouped withCover:self.theCover withContext:context];
        [self.mediaTableViewController setDelegate:self];
        
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"exportpage.png"]];
        self.view.backgroundColor = background;
        
        self.exportTableViewController.tableView.backgroundView.alpha = 0;
        self.exportTableViewController.tableView.frame = CGRectMake(50,200,400,450);
        
        self.mediaTableViewController.tableView.frame = CGRectMake(570,200,370,480);
        self.mediaTableViewController.tableView.backgroundView.alpha = 0;
        
        [self.view addSubview:self.exportTableViewController.tableView];
        [self.view addSubview:self.mediaTableViewController.tableView];
    }
    
    return self;
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
- (void) loadAddCreditsPopover
{
    AddCreditsViewController *addCreditsViewController = [[AddCreditsViewController alloc] init];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:addCreditsViewController];
    [popoverController presentPopoverFromRect:self.addCreditsButton.frame inView:[[UIApplication sharedApplication] keyWindow] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) reloadMediaTable
{
//    NSLog(@"WAS I CALLED?");
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
    
    [self loadAddCreditsPopover];
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
    NSLog(@"uploadSuccess");
    [self.facebookUploaderViewController.view removeFromSuperview];
   [self.facebookUploaderViewController release];
}

- (void)facebookUploadFailed
{
    
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

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
@synthesize background;
@synthesize exportTableViewController;
@synthesize mediaTableViewController;
    
- (ExportViewController*)initWithStuff:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext;
{
    self = [super init];
    if (self) {
        self.theShow = show;
        self.theCover = cover;
        self.context = aContext;
        
        self.exportTableViewController = [[ExportTableViewController alloc] initWithStyle:UITableViewStyleGrouped :theShow :theCover context:context];
        [self.exportTableViewController setDelegate:self];
        
        self.mediaTableViewController = [[MediaTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.mediaTableViewController setDelegate:self];
        
        self.background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"exportpage.png"]];
        self.view.backgroundColor = background;
        
//        self.exportTableViewController.tableView.backgroundView.alpha = 0;
        self.exportTableViewController.tableView.frame = CGRectMake(50,200,400,450);
        
        self.mediaTableViewController.tableView.frame = CGRectMake(570,200,370,480);
//        self.mediaTableViewController.tableView.backgroundView.alpha = 0;
        
        [self.view addSubview:self.exportTableViewController.tableView];
        [self.view addSubview:self.mediaTableViewController.tableView];
    }
    
    return self;
}

- (void) addExportedAsset: (ExportedAsset*) asset
{
    
}

- (void) playMovie:(NSURL*)filePath
{
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:filePath];
    
    // Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)]) {
        // Use the new 3.2 style API
        
        [moviePlayer setFullscreen:YES animated:YES];
        [moviePlayer.view setFrame:self.view.bounds];
        moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        moviePlayer.shouldAutoplay = YES;
        //        [self.view setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:moviePlayer.view];
        self.navigationController.navigationBarHidden = YES;
        [moviePlayer play];
    }   
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

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc
{
    [super dealloc];
    [mediaTableViewController release];
    [exportTableViewController release];
    [background release];
}

@end

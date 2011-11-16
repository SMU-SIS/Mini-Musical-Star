//
//  AudioEditorViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 16/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioEditorViewController.h"

@implementation AudioEditorViewController

@synthesize delegate;

@synthesize recordingStatusLabel;
@synthesize tutorialButton;

@synthesize tracksTableView;
@synthesize lyricsView;

@synthesize tracksTableViewController;
@synthesize lyricsViewController;

@synthesize theScene;
@synthesize theCoverScene;
@synthesize playPauseButton;
@synthesize context;

#pragma mark - initializers and deinitializers

- (AudioEditorViewController *)initWithScene:(Scene *)aScene andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext;
{
    self = [super init];
    if (self) {
        self.theScene = aScene;
        self.theCoverScene = aCoverScene;
        self.context = aContext;

        tracksTableViewController = [[TracksTableViewController alloc] initWithScene:aScene andACoverScene:aCoverScene andAContext:aContext andARecordingStatusLabel:recordingStatusLabel];
        
        lyricsViewController = [[LyricsViewController alloc] init];
        
    }
    
    return self;
}

- (void)dealloc
{
    [recordingStatusLabel release];
    [tracksTableView release];
    [lyricsView release];
    
    [tracksTableViewController release];
    [lyricsViewController release];
    
    [theScene release];
    [theCoverScene release];
    [context release];
    [playPauseButton release];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tracksTableView addSubview:tracksTableViewController.tableView];
    [self.lyricsView addSubview:lyricsViewController.view];
    
    self.tracksTableView.clipsToBounds = YES;
    
    CGRect tracksTableViewFrame = tracksTableView.frame;
    CGRect newSize = tracksTableViewController.tableView.frame;
    newSize.size.width = tracksTableViewFrame.size.width;
    newSize.size.height = tracksTableViewFrame.size.height;
    self.tracksTableViewController.tableView.frame = newSize;
    
    CGRect lyricsViewControllerFrame = lyricsViewController.view.frame;
    lyricsViewControllerFrame.origin.x = 0;
    lyricsViewControllerFrame.origin.y = 0;
    lyricsViewController.view.frame = lyricsViewControllerFrame;
    
//    NSLog(@"lyrics view frame: %@", NSStringFromCGRect(lyricsView.frame));
//    NSLog(@"lyrics from scroll view : %@", NSStringFromCGRect(lyricsViewController.view.frame));
    
    self.tracksTableViewController.playPauseButton = self.playPauseButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.recordingStatusLabel = nil;
    self.tracksTableView = nil;
    self.lyricsView = nil;
}

#pragma mark - other generate methods

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - instance methods



#pragma mark - IBAction
- (IBAction) playTutorial:(id)sender
{
    //play tutorial video player
    [delegate playMovie:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio" ofType:@"m4v"]]];
}


@end

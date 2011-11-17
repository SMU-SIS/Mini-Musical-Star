//
//  AudioEditorViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 16/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioEditorViewController.h"
#import "Cue.h"

@implementation AudioEditorViewController

@synthesize delegate;

@synthesize recordingStatusLabel;
@synthesize tutorialButton;

@synthesize tracksTableView;
@synthesize lyricsView;

@synthesize tracksTableViewController;
@synthesize lyricsViewController;

@synthesize cueController;
@synthesize cueView;

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
        
        //load the cueController.
        self.cueController = [[CueController alloc] initWithAudioArray:self.tracksTableViewController.tracksForView];
        self.cueController.delegate = self;
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
    
    [cueController release];
    [cueView release];
    
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

- (void)removeAndUnloadCueFromView
{
    if (self.cueView && self.cueController.currentCue)
    {
        //animate the lyrics view sliding up
        CGRect lyricsFrame = self.lyricsView.frame;
        lyricsFrame.origin.y = lyricsFrame.origin.y - 50;
        lyricsFrame.size.height = lyricsFrame.size.height + 50;
        
        //        CGRect lyricsLabelFrame = self.lyricsLabel.frame;
        //        lyricsLabelFrame.origin.y = lyricsLabelFrame.origin.y - 50;
        //        lyricsLabelFrame.size.height = lyricsLabelFrame.size.height + 50;
        //        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.lyricsView.frame = lyricsFrame;
                             //                             self.lyricsLabel.frame = lyricsLabelFrame;
                         }
                         completion:^(BOOL finished) {
                             [self.cueView removeFromSuperview];
                             self.cueController.currentCue = nil;
                             self.cueView = nil;
                         }];
    }
}

#pragma mark - TracksTableViewDelegate methods

- (void)cueButtonIsPressed:(int)trackIndex
{    
    Cue *theCue = [self.cueController getCurrentCueForTrackIndex:trackIndex];
    
    if (self.cueController.currentCue == theCue)
    {
        [self removeAndUnloadCueFromView];
    }
    
    //change the cue only if a different cue is requested
    else if (self.cueController.currentCue != theCue)
    {
        [self removeAndUnloadCueFromView];
        self.cueController.currentCue = theCue;
        
        CGRect frame = CGRectMake(520, 30, 460, 50);
        
        UITextView *textView = [[UITextView alloc] initWithFrame:frame];
        textView.frame = frame;
        textView.text = theCue.content;
        
        self.cueView = textView;
        [textView release];
        
        [self.view addSubview:self.cueView];
        [self.view sendSubviewToBack:self.cueView];
        
        //animate the lyrics view sliding down
        CGRect lyricsFrame = self.lyricsView.frame;
        lyricsFrame.origin.y = lyricsFrame.origin.y + 50;
        lyricsFrame.size.height = lyricsFrame.size.height - 50;
        
//        CGRect lyricsLabelFrame = self.lyricsLabel.frame;
//        lyricsLabelFrame.origin.y = lyricsLabelFrame.origin.y + 50;
//        lyricsLabelFrame.size.height = lyricsLabelFrame.size.height - 50;
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.lyricsView.frame = lyricsFrame;
                             //self.lyricsLabel.frame = lyricsLabelFrame;
                         }
                         completion:^(BOOL finished) {
                             NSLog(@"animation done!");
                         }];
        
    }
}

#pragma mark - IBAction
- (IBAction) playTutorial:(id)sender
{
    //play tutorial video player
    [delegate playMovie:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio" ofType:@"m4v"]]];
}

#pragma mark - instance methods for cues
- (void)setCueButton:(BOOL)shouldShow forTrackIndex:(NSUInteger)trackIndex
{
    [self.tracksTableViewController setCueButton:shouldShow forTrackIndex:trackIndex];
}

@end

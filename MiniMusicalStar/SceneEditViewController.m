//
//  CrollUIViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#define kNumberOfPages 2
#import "SceneEditViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TracksTableViewController.h"

@implementation SceneEditViewController

@synthesize context;
@synthesize containerToggleButton;
@synthesize delegate;
@synthesize theScene, theCoverScene;
@synthesize containerView, audioView, photoView;
@synthesize playPauseButton;
@synthesize elapsedTimeLabel, totalTimeLabel, songInfoLabel, playPositionSlider, micVolumeSlider;

- (void)dealloc
{   
    [delegate release];
    [audioView release];
    [photoView release];
    [playPauseButton release];
    [containerView release];
    [elapsedTimeLabel release];
    [totalTimeLabel release];
    [songInfoLabel release];
    [playPositionSlider release];
    [micVolumeSlider release];
    [theScene release];
    [theCoverScene release];
    [context release];
    [containerToggleButton release];
    
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (SceneEditViewController *)initWithScene:(Scene *)aScene andSceneCover:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self)
    {
        self.theScene = aScene;
        self.theCoverScene = aCoverScene;
        self.context = aContext;
        
        isAlertShown = NO;
        
        [self loadChildViewControllers];
    }
    
    return self;
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStartedNotification:) name:kMixPlayerRecorderPlaybackStarted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStoppedNotification:) name:kMixPlayerRecorderPlaybackStopped object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveElapsedTimeNotification:) name:kMixPlayerRecorderPlaybackElapsedTimeAdvanced object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBringSliderToZeroNotification) name:kBringSliderToZero object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerNotifications];
    
    self.audioView.playPauseButton = self.playPauseButton;
    
    [containerView addSubview:audioView.view];
    photoView.view.hidden = YES;
    [containerView addSubview:photoView.view];
    
    //add the toggle button the nav bar
    

    //update the total time label
    //[totalTimeLabel setText:[NSString stringWithFormat:@"%lu", thePlayer.totalPlaybackTimeInSeconds]];
    [totalTimeLabel setText:[NSString stringWithFormat:@"%lu:%0.2lu", [self.audioView.tracksTableViewController.thePlayer totalPlaybackTimeInSeconds]/60, [self.audioView.tracksTableViewController.thePlayer totalPlaybackTimeInSeconds]%60]];
    
    //update the song title
    [songInfoLabel setText:theScene.title];

    //set the mic volume control value
    micVolumeSlider.value = [self.audioView.tracksTableViewController.thePlayer getMicVolume];
    
    [self drawPlaySlider];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [audioView.view removeFromSuperview];
    
    //self.audioView.delegate = nil;
    //self.audioView.tracksTableViewController.delegate = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
     containerToggleButton = [[UIBarButtonItem alloc] initWithTitle:@"Photos" style:UIBarButtonItemStylePlain target:self action:@selector(toggleContainerView)];          
    self.navigationItem.rightBarButtonItem = containerToggleButton;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [audioView.tracksTableViewController deRegisterFromNSNotifcationCenter];
}

#pragma mark - IBActions

- (IBAction)playPauseButtonPressed:(UIButton *)sender
{
    [self.audioView.tracksTableViewController playPauseButtonIsPressed];
}

- (IBAction)toggleContainerView
{
	if (transitioning) return;
    
    // First create a CATransition object to describe the transition
	CATransition *transition = [CATransition animation];
	// Animate over 1/4 of a second
	transition.duration = 0.25;
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    
    transition.delegate = self;
    
    
    transitioning = YES;
    
    if (audioView.view.hidden == NO && photoView.view.hidden == YES)
    {
        transition.subtype = kCATransitionFromTop;
        [containerView.layer addAnimation:transition forKey:nil];
        
        audioView.view.hidden = YES;
        photoView.view.hidden = NO;
        
        containerToggleButton.title = @"Audio";
    }
    
    else 
    {
        transition.subtype = kCATransitionFromBottom;
        [containerView.layer addAnimation:transition forKey:nil];
        
        audioView.view.hidden = NO;
        photoView.view.hidden = YES;
        
        containerToggleButton.title = @"Photos";
    }
}

- (IBAction)micVolumeSliderDidMove:(UISlider *)sender
{
    //this adjusts the mic volume
    //[thePlayer setMicVolume:sender.value];
    [self.audioView.tracksTableViewController.thePlayer setMicVolume:sender.value];
}

- (IBAction)toggleSeek:(UISlider *)sender
{
    //convert the float value to seconds
    int targetSeconds = sender.value * [self.audioView.tracksTableViewController.thePlayer totalPlaybackTimeInSeconds];
    [self setSliderPosition:targetSeconds];
    
}

#pragma mark - Instance methods

- (void)loadChildViewControllers
{
    //load the audio view controller
    audioView = [[AudioEditorViewController alloc] initWithScene:theScene andCoverScene:theCoverScene andContext:context];
    
    self.audioView.delegate = self;
    self.audioView.tracksTableViewController.lyricsViewControllerDelegate = audioView.lyricsViewController;
    self.audioView.tracksTableViewController.audioEditorViewControllerDelegate = self.audioView;
    
    //load the photo view controller
    photoView = [[PhotoEditorViewController alloc] initWithScene:theScene andCoverScene:theCoverScene andContext:context];
    [photoView setDelegate:self];
}

- (NSArray*) getExportAudioURLs{
    return [audioView.tracksTableViewController getExportAudioURLs];
}

- (void)setSliderPosition:(int) targetSeconds
{
    if (self.audioView.tracksTableViewController.thePlayer.isRecording)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Sorry, you can't seek while recording!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
    else
    {
        //convert the float value to seconds
        if (self.audioView.tracksTableViewController.thePlayer.isPlaying)
            //if the player is playing
        {
            [self.audioView.tracksTableViewController.thePlayer seekTo:targetSeconds];
        }
        
        else
        {
            //if the player is not playing
            [self.audioView.tracksTableViewController.thePlayer seekTo:targetSeconds];
            [self.audioView.tracksTableViewController.thePlayer stop];
        }
    }
}

- (void)stopPlayer
{
    [self.audioView.tracksTableViewController.thePlayer stop];
}

-(BOOL)isRecording
{
    return [audioView.tracksTableViewController isRecording];
}

#pragma mark - notifys and callbacks

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	transitioning = NO;
}

-(void)didReceiveElapsedTimeNotification:(NSNotification *)notification
{
    //need to alloc the NSNumber because there is no autorelease pool in the secondary thread
    [self performSelectorOnMainThread:@selector(updateProgressSliderWithTime) withObject:nil waitUntilDone:NO];
    
    
}

//for the secondary thread to call on the main thread
-(void)updateProgressSliderWithTime
{
    //inform the PhotoEditorViewController
    [photoView setSliderImages:[self.audioView.tracksTableViewController.thePlayer elapsedPlaybackTimeInSeconds]];
    
    //update the playback labels
    [elapsedTimeLabel setText:[NSString stringWithFormat:@"%i:%0.2i", [self.audioView.tracksTableViewController.thePlayer elapsedPlaybackTimeInSeconds]/60, [self.audioView.tracksTableViewController.thePlayer elapsedPlaybackTimeInSeconds]%60]];
    float progressSliderValue = (float)[self.audioView.tracksTableViewController.thePlayer elapsedPlaybackTimeInSeconds] / (float)[self.audioView.tracksTableViewController.thePlayer totalPlaybackTimeInSeconds];    
    playPositionSlider.value = progressSliderValue;
}

-(void)didReceivePlayerStoppedNotification:(NSNotification *)notification
{
    [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
}

-(void)didReceivePlayerStartedNotification:(NSNotification *)notification
{
    [playPauseButton setTitle:@"Stop" forState:UIControlStateNormal];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveBringSliderToZeroNotification
{
    [self setSliderPosition:0];
}

-(void)drawPlaySlider
{
    // Setup custom slider images
	UIImage *maxImage = [UIImage imageNamed:@"scrollerBack.png"];
	UIImage *minImage = [UIImage imageNamed:@"scrollerFront.png"];
	UIImage *tumbImage= [UIImage imageNamed:@"star.png"];
	UIImage *micImage = [UIImage imageNamed:@"micScroller.png"];
    
	minImage=[minImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	maxImage=[maxImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    
	// Setup the Playback slider
	[playPositionSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
	[playPositionSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
	[playPositionSlider setThumbImage:tumbImage forState:UIControlStateNormal];
    
    playPositionSlider.continuous = YES;
    
    // Setup the MicVolume Slider
    [micVolumeSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
	[micVolumeSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [micVolumeSlider setThumbImage:micImage forState:UIControlStateNormal];
    
    micVolumeSlider.continuous = YES;
}

#pragma mark - AudioViewDelegate methods

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

@end

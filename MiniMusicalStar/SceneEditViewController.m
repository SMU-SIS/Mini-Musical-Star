//
//  CrollUIViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#define kNumberOfPages 2
#import "SceneEditViewController.h"

@implementation SceneEditViewController
@synthesize audioView, photoView, playPauseButton, containerView, elapsedTimeLabel, totalTimeLabel, songInfoLabel, playPositionSlider, micVolumeSlider, theScene, theCoverScene, context, containerToggleButton;

- (void)dealloc
{
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

- (void)loadChildViewControllers
{
    //load the audio view controller
    audioView = [[AudioEditorViewController alloc] initWithScene:theScene andCoverScene:theCoverScene andContext:context andPlayPauseButton:playPauseButton];

    //load the photo view controller
    photoView = [[PhotoEditorViewController alloc] initWithScene:theScene andCoverScene:theCoverScene andContext:context];
    [photoView setDelegate:self];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStartedNotification:) name:kMixPlayerRecorderPlaybackStarted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStoppedNotification:) name:kMixPlayerRecorderPlaybackStopped object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveElapsedTimeNotification:) name:kMixPlayerRecorderPlaybackElapsedTimeAdvanced object:nil];
}

- (NSArray*) getExportAudioURLs{
    return [audioView getExportAudioURLs];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerNotifications];
    
    [audioView giveMePlayPauseButton:playPauseButton];
    
    [containerView addSubview:audioView.view];
    photoView.view.hidden = YES;
    [containerView addSubview:photoView.view];
    
    //add the toggle button the nav bar
    
    
    //update the total time label
    //[totalTimeLabel setText:[NSString stringWithFormat:@"%lu", thePlayer.totalPlaybackTimeInSeconds]];
    [totalTimeLabel setText:[NSString stringWithFormat:@"%lu:%0.2lu", [self.audioView.thePlayer totalPlaybackTimeInSeconds]/60, [self.audioView.thePlayer totalPlaybackTimeInSeconds]%60]];
    
    //update the song title
    [songInfoLabel setText:theScene.title];

    //set the mic volume control value
    micVolumeSlider.value = [self.audioView.thePlayer getMicVolume];
    
}

- (void)viewWillAppear:(BOOL)animated
{
     containerToggleButton = [[UIBarButtonItem alloc] initWithTitle:@"Photos" style:UIBarButtonItemStylePlain target:self action:@selector(toggleContainerView)];          
    self.navigationItem.rightBarButtonItem = containerToggleButton;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [audioView deRegisterFromNSNotifcationCenter];
}

#pragma mark IBActions

- (IBAction)playPauseButtonPressed: (UIButton *)sender
{
    [self playPauseButtonIsPressed];
}

- (void)playPauseButtonIsPressed
{
    
    if ([self.audioView.thePlayer isPlaying] && [audioView isRecording] == NO)
    {
        [self.audioView.thePlayer stop];
        [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.audioView stopButtonIsPresssed];
    }
    else
    {
        if ([audioView isRecording] == YES) {
            
            if (isAlertShown == YES)
            {
                if (isReallyStop == YES)
                {
                    //[self.audioView.thePlayer stop]; //let audio view handle stopping.
                    [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
                    [self.audioView stopButtonIsPresssed];
                }
                
                isAlertShown = NO;
            }
            else
            {
                [self showReallyAlertView]; 
            }
            
            
        }
        else 
        {
            [self.audioView.thePlayer play];
            [playPauseButton setTitle:@"Stop" forState:UIControlStateNormal];
            [self.audioView playButtonIsPressed];
        }
    }
    
}

- (IBAction)micVolumeSliderDidMove:(UISlider *)sender
{
    //this adjusts the mic volume
    //[thePlayer setMicVolume:sender.value];
    [self.audioView.thePlayer setMicVolume:sender.value];
}

- (IBAction)toggleSeek:(UISlider *)sender
{
    //convert the float value to seconds
    int targetSeconds = sender.value * [self.audioView.thePlayer totalPlaybackTimeInSeconds];
    [self setSliderPosition:targetSeconds];
    
}

- (void)setSliderPosition:(int) targetSeconds
{
    if (self.audioView.thePlayer.isRecording)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Sorry, you can't seek while recording!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
    else
    {
        //convert the float value to seconds
        if (self.audioView.thePlayer.isPlaying)
        {
            [self.audioView.thePlayer seekTo:targetSeconds];
        }
        
        else
        {
            [self.audioView.thePlayer seekTo:targetSeconds];
            [self.audioView.thePlayer stop];
        }
    }
}

- (void)stopPlayer
{
    [self.audioView.thePlayer stop];
}

-(BOOL)isRecording
{
    return [audioView isRecording];
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

#pragma mark notifys and callbacks

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
    [photoView setSliderImages:[self.audioView.thePlayer elapsedPlaybackTimeInSeconds]];
    
    //update the playback labels
    [elapsedTimeLabel setText:[NSString stringWithFormat:@"%i:%0.2i", [self.audioView.thePlayer elapsedPlaybackTimeInSeconds]/60, [self.audioView.thePlayer elapsedPlaybackTimeInSeconds]%60]];
    float progressSliderValue = (float)[self.audioView.thePlayer elapsedPlaybackTimeInSeconds] / (float)[self.audioView.thePlayer totalPlaybackTimeInSeconds];    
    playPositionSlider.value = progressSliderValue;
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
        
        [moviePlayer.view setFrame:self.view.bounds];
        moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        moviePlayer.shouldAutoplay = YES;
        [self.view setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:moviePlayer.view];
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
    
    [moviePlayer release];
}

-(void)didReceivePlayerStoppedNotification:(NSNotification *)notification
{
    [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
}

-(void)didReceivePlayerStartedNotification:(NSNotification *)notification
{
    [playPauseButton setTitle:@"Stop" forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark UIAlertViewDelegate Protocol methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) 
    {
        isReallyStop = YES;
    }
    else
    {
        //user pressed no
        isReallyStop = NO;
    }
    
    isAlertShown = YES;
    
    [self playPauseButtonIsPressed];
}

- (void)showReallyAlertView
{
    UIAlertView *reallyStopAlertView = [[UIAlertView alloc] initWithTitle:@"Stop?" message:@"Do you really want to stop? :(" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    [reallyStopAlertView show];
}

@end

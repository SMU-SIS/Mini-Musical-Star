//
//  FourthAttemptViewController.m
//  FourthAttempt
//
//  Created by Jun Kit Lee on 11/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "FourthAttemptViewController.h"

@implementation FourthAttemptViewController
@synthesize slider, segmentedControl, togglePlaybackButton, progressSlider;

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
    
    //register notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStartedNotification:) name:kMixPlayerRecorderPlaybackStarted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStoppedNotification:) name:kMixPlayerRecorderPlaybackStopped object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveElapsedTimeNotification:) name:kMixPlayerRecorderPlaybackElapsedTimeAdvanced object:nil];
    
    NSString *bass = [[NSBundle mainBundle] pathForResource:@"bass" ofType:@"mp3"];
    NSString *drums = [[NSBundle mainBundle] pathForResource:@"drums" ofType:@"mp3"];
    NSString *guitar = [[NSBundle mainBundle] pathForResource:@"guitar" ofType:@"mp3"];
    NSString *keys = [[NSBundle mainBundle] pathForResource:@"keys" ofType:@"mp3"];
    NSString *vocals = [[NSBundle mainBundle] pathForResource:@"vocals" ofType:@"mp3"];
    
    NSArray *audioFiles = [NSArray arrayWithObjects:[NSURL fileURLWithPath:bass], [NSURL fileURLWithPath:drums], [NSURL fileURLWithPath:guitar], [NSURL fileURLWithPath:keys], [NSURL fileURLWithPath:vocals], nil];
    
    player = [[MixPlayerRecorder alloc] initWithAudioFileURLs:audioFiles];
}

- (IBAction)volumeSliderDidMove:(UISlider *)sender
{
    int segmentIndex = [segmentedControl selectedSegmentIndex];
    float vol = sender.value;
    
    [player setVolume:vol forBus:segmentIndex];
}

- (IBAction)segmentedControlDidChange:(UISegmentedControl *)sender
{
    int segmentIndex = [segmentedControl selectedSegmentIndex];
    float currentVol = [player getVolumeForBus:segmentIndex];
    
    slider.value = currentVol;
}

- (IBAction)togglePlaybackButtonDidPress:(UIButton *)sender
{
    if (player.isPlaying)
    {
        [player stop];
        [sender setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    else
    {
        [player play];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (IBAction)toggleSeek:(UISlider *)sender
{
    //convert the float value to seconds
    int targetSeconds = sender.value * player.totalPlaybackTimeInSeconds;
    [player seekTo:targetSeconds];
    
}

#pragma mark - NSNotificationCenter callbacks
-(void)didReceiveElapsedTimeNotification:(NSNotification *)notification
{
    float progressSliderValue = (float)player.elapsedPlaybackTimeInSeconds / (float)player.totalPlaybackTimeInSeconds;
    
    //need to alloc the NSNumber because there is no autorelease pool in the secondary thread
    [self performSelectorOnMainThread:@selector(updateProgressSliderWithTime:) withObject:[[NSNumber alloc] initWithFloat:progressSliderValue] waitUntilDone:NO];
    
}

//for the secondary thread to call on the main thread
-(void)updateProgressSliderWithTime:(NSNumber *)elapsedTime
{
    progressSlider.value = [elapsedTime floatValue];
    [elapsedTime release];
}
     
 -(void)didReceivePlayerStoppedNotification:(NSNotification *)notification
 {
     [togglePlaybackButton setTitle:@"Play" forState:UIControlStateNormal];
 }

-(void)didReceivePlayerStartedNotification:(NSNotification *)notification
{
    [togglePlaybackButton setTitle:@"Stop" forState:UIControlStateNormal];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    
    [slider release];
    [progressSlider release];
    [segmentedControl release];
    [togglePlaybackButton release];
    [player release];
    [super dealloc];
}

@end

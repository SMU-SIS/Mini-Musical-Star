//
//  FourthAttemptViewController.m
//  FourthAttempt
//
//  Created by Jun Kit Lee on 11/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "AudioViewController.h"

@implementation AudioViewController
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
    
    audioFiles = [NSArray arrayWithObjects:[NSURL fileURLWithPath:bass], [NSURL fileURLWithPath:drums], [NSURL fileURLWithPath:guitar], [NSURL fileURLWithPath:keys], [NSURL fileURLWithPath:vocals], nil];
    
    player = [[MixPlayerRecorder alloc] initWithAudioFileURLs:audioFiles];
    
    //[self makeAudioList];
    
    //create temp file for recording
    NSString *tempRecordingFile = [NSTemporaryDirectory() stringByAppendingString:@"recording.m4a"];
    [player enableRecordingToFile:[NSURL fileURLWithPath:tempRecordingFile]];
    
    NSLog(@"temp file is %@\n", tempRecordingFile);
     
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

-(void)makeAudioList
{
    //Hard coded the names of the tracks. Is there a way to get the name of the tracks from the audio object?
    NSArray *trackNames =[[NSArray alloc] initWithObjects:[NSString stringWithString:@"Bass"],[NSString stringWithString:@"Drums"],[NSString stringWithString:@"Guitar"], [NSString stringWithString:@"Keys"],[NSString stringWithString:@"Vocals"], nil];
    
    for (int i=0; i<trackNames.count; i++) {
        //The display pf the tracks will always be centralized according to the number of tracks
        CGRect frame = CGRectMake(0, (self.view.frame.size.height-trackNames.count*50)/2+(i*50), 480, 100);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
    
        NSString *name = [trackNames objectAtIndex:i];
        
        //creating UIlabel to format the Track names
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 400, 50)];
        [titleLable setText:name];
        [titleLable setTextColor:[UIColor whiteColor]];
        [titleLable setBackgroundColor:[UIColor blackColor]];
        [titleLable setTextAlignment:UITextAlignmentLeft];
        [titleLable setFont:[UIFont fontWithName:@"verdana" size:25]];

        //adding the label to the button then to the main view
        [button addSubview:titleLable];
        [button setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:button];
        [button release];
        [titleLable release];
    }
    [trackNames release];
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

-(void)stopPlayer
{
    [player stop];
}

- (void)dealloc
{
    
    [slider release];
    [progressSlider release];
    [segmentedControl release];
    [togglePlaybackButton release];
    [player stop];
    [player release];
    [super dealloc];
}

@end

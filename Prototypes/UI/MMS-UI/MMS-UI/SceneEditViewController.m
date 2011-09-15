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
@synthesize audioView, photoView, scrollView, pageControl, playPauseButton, elapsedTimeLabel, totalTimeLabel, songInfoLabel, playPositionSlider, masterVolumeSlider, theScene, thePlayer;

- (void)dealloc
{
    [thePlayer stop];
    [thePlayer release];
    [theScene release];
    [scrollView release];
    [pageControl release];
    [playPauseButton release];
    [elapsedTimeLabel release];
    [totalTimeLabel release];
    [songInfoLabel release];
    [playPositionSlider release];
    [masterVolumeSlider release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStartedNotification:) name:kMixPlayerRecorderPlaybackStarted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePlayerStoppedNotification:) name:kMixPlayerRecorderPlaybackStopped object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveElapsedTimeNotification:) name:kMixPlayerRecorderPlaybackElapsedTimeAdvanced object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //update the total time label
    [totalTimeLabel setText:[NSString stringWithFormat:@"%lu", thePlayer.totalPlaybackTimeInSeconds]];
    
    //update the song title
    [songInfoLabel setText:theScene.title];
    
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    
    [self loadChildViewControllers];
    
}

- (void)loadChildViewControllers
{
    //load the audio view controller
    audioView = [[AudioEditorViewController alloc] initWithPlayer:thePlayer andAudioObjects:theScene.audioList];
    int page = 0;
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    audioView.view.frame = frame;
    [scrollView addSubview:audioView.view];
    
    //load the photo view controller
    photoView = [[PhotoEditorViewController alloc] initWithPhotos:theScene.pictureList andParent:self];
    page = 1;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    photoView.view.frame = frame;
    [scrollView addSubview:photoView.view];

}

- (SceneEditViewController *)initWithScene:(Scene *)aScene
{
    self = [super init];
    if (self)
    {
        self.theScene = aScene;
        
        //get the array of audio tracks
        __block NSMutableArray *audioTracks = [[NSMutableArray alloc] initWithCapacity:aScene.audioList.count];
        [aScene.audioList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Audio *theAudio = (Audio *)obj;
            [audioTracks addObject:[NSURL fileURLWithPath:theAudio.path]];
        }];
        
        //init the player with the audio tracks
        thePlayer = [[MixPlayerRecorder alloc] initWithAudioFileURLs:audioTracks];
        
        [self registerNotifications];
    }
    
    return self;
}

#pragma mark IBActions

- (IBAction)playPauseButtonPressed: (UIButton *)sender
{
    if (thePlayer.isPlaying)
    {
        [thePlayer stop];
        [sender setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    else
    {
        [thePlayer play];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (IBAction)volumeSliderDidMove:(UISlider *)sender
{
    NSLog(@"This has no effect because I haven't found a way to change the master volume.\n");
}

- (IBAction)toggleSeek:(UISlider *)sender
{
    //convert the float value to seconds
    int targetSeconds = sender.value * thePlayer.totalPlaybackTimeInSeconds;
    [thePlayer seekTo:targetSeconds];
    
}

- (void)setSliderPosition:(int) targetSeconds
{
    //convert the float value to seconds
    [thePlayer seekTo:targetSeconds];
    
}


#pragma mark notifys and callbacks

-(void)didReceiveElapsedTimeNotification:(NSNotification *)notification
{
    //need to alloc the NSNumber because there is no autorelease pool in the secondary thread
    [self performSelectorOnMainThread:@selector(updateProgressSliderWithTime) withObject:nil waitUntilDone:NO];
    
}

//for the secondary thread to call on the main thread
-(void)updateProgressSliderWithTime
{
    //inform the PhotoEditorViewController
    [photoView setSliderImages:thePlayer.elapsedPlaybackTimeInSeconds];
    
    //update the playback labels
    [elapsedTimeLabel setText:[NSString stringWithFormat:@"%i", thePlayer.elapsedPlaybackTimeInSeconds]];
    float progressSliderValue = (float)thePlayer.elapsedPlaybackTimeInSeconds / (float)thePlayer.totalPlaybackTimeInSeconds;    
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

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
    int page = pageControl.currentPage;
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end

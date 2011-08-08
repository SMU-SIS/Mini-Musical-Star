    //
//  NGMoviePlayerViewController.m
//  bobcat
//
//  Created by Brent Simmons on 8/14/10.
//  Copyright 2010 NewsGator Technologies, Inc. All rights reserved.
//

#import "NGMoviePlayerViewController.h"
#import "NGMoviePlayerUpperControlsView.h"
#import "NGMoviePlayerLowerControlsView.h"


@interface NGMoviePlayerViewController ()

@property (nonatomic, retain) NSURL *contentURL;
@property (nonatomic, assign) BOOL didNotifyDelegate;
@property (nonatomic, retain) NSTimer *hideControlsTimer;
@property (nonatomic, assign, readwrite) BOOL loadingMovie;
@property (nonatomic, retain) NSTimer *moveTimer;
@property (nonatomic, assign) CMTime movieDuration;
@property (nonatomic, retain, readwrite) NSError *movieError;
@property (nonatomic, assign) BOOL originalStatusBarHidden;
@property (nonatomic, assign) UIStatusBarStyle originalStatusBarStyle;
@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) float rateToRestoreAfterScrubbing;
@property (nonatomic, retain) id timeObserver;
@property (nonatomic, retain) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, retain) UILongPressGestureRecognizer *rewindButtonLongPressGestureRecognizer;
@property (nonatomic, retain) UILongPressGestureRecognizer *fastForwardButtonLongPressGestureRecognizer;
@property (nonatomic, assign) id delegate;

- (void)loadPlayer;
- (void)startHideControlsTimer;
- (BOOL)playerIsPaused;
- (Float64)durationInSeconds;
- (Float64)currentTimeInSeconds;
- (Float64)timeRemainingInSeconds;
- (void)notifyDelegateThatMovieDidFinish;
- (void)stopMoveTimer;
- (void)removeTimeObserver;
- (void)turnOffHideControlsTimer;
- (void)checkIfAtEndOfMovie;

@end


@implementation NGMoviePlayerViewController

@synthesize contentURL;
@synthesize controlsView;
@synthesize didNotifyDelegate;
@synthesize doneButton;
@synthesize fastForwardButton;
@synthesize hideControlsTimer;
@synthesize loadingMovie;
@synthesize moveTimer;
@synthesize movieDuration;
@synthesize movieError;
@synthesize originalStatusBarHidden;
@synthesize originalStatusBarStyle;
@synthesize player;
@synthesize playerLayer;
@synthesize playPauseButton;
@synthesize rateToRestoreAfterScrubbing;
@synthesize rewindButton;
@synthesize slider;
@synthesize timeElapsedLabel;
@synthesize timeObserver;
@synthesize timeRemainingLabel;
@synthesize upperControlsView;
@synthesize singleTapGestureRecognizer;
@synthesize rewindButtonLongPressGestureRecognizer;
@synthesize fastForwardButtonLongPressGestureRecognizer;
@synthesize delegate;

#pragma mark -
#pragma mark Init

- (id)initWithContentURL:(NSURL *)aContentURL delegate:(id)aDelegate {
	self = [super initWithNibName:@"NGMoviePlayer" bundle:nil];
	if (self == nil)
		return nil;
	delegate = aDelegate;
	contentURL = [aContentURL retain];
	originalStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
	originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
	movieDuration = kCMTimeInvalid;
	return self;
}

- (id)initWithAVAsset:(AVAsset *)aAVAsset delegate:(id)aDelegate {
	self = [super initWithNibName:@"NGMoviePlayer" bundle:nil];
	if (self == nil)
		return nil;
	delegate = aDelegate;
	theAVAsset = [aAVAsset retain];
	originalStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
	originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
	movieDuration = kCMTimeInvalid;
	return self;
}


#pragma mark Dealloc

- (void)dealloc {
	/*Yes, the below is done in cleanup, but we do it here again just in case.
	 Can't call cleanup because the rule is direct-access-only in dealloc.*/
	delegate = nil;
	if (hideControlsTimer != nil && [hideControlsTimer isValid])
		[hideControlsTimer invalidate];
	[hideControlsTimer release];
	if (moveTimer != nil && [moveTimer isValid])
		[moveTimer invalidate];
	[moveTimer release];
	[player removeTimeObserver:timeObserver];
	[timeObserver release];
	[player removeObserver:self forKeyPath:@"status"];
	[player removeObserver:self forKeyPath:@"currentItem.asset.duration"];
	[player removeObserver:self forKeyPath:@"currentItem.error"];
	
	[contentURL release];
	[controlsView release];
	[doneButton release];
	[fastForwardButton release];
	[movieError release];
	[player release];
	[playerLayer release];
	[playPauseButton release];
	[rewindButton release];
	[slider release];
	[timeElapsedLabel release];
	[timeRemainingLabel release];
	[upperControlsView release];
	[singleTapGestureRecognizer release];
	[rewindButtonLongPressGestureRecognizer release];
	[fastForwardButtonLongPressGestureRecognizer release];
	[super dealloc];
}


- (void)cleanup {
	[self removeTimeObserver];
	[self stopMoveTimer];
	[self turnOffHideControlsTimer];
	[self.player removeObserver:self forKeyPath:@"status"];
	[self.player removeObserver:self forKeyPath:@"currentItem.asset.duration"];
	[self.player removeObserver:self forKeyPath:@"currentItem.error"];
	[self.view removeGestureRecognizer:self.singleTapGestureRecognizer];
	self.singleTapGestureRecognizer = nil;
	[self.rewindButton removeGestureRecognizer:self.rewindButtonLongPressGestureRecognizer];
	self.rewindButtonLongPressGestureRecognizer = nil;
	[self.fastForwardButton removeGestureRecognizer:self.fastForwardButtonLongPressGestureRecognizer];
	self.fastForwardButtonLongPressGestureRecognizer = nil;
	[self.playerLayer removeFromSuperlayer];
	self.playerLayer = nil;
	self.player = nil;
	self.contentURL = nil;
}


#pragma mark UIViewController

- (void)viewDidLoad {
	
	[self.doneButton setBackgroundImage:[[UIImage imageNamed:@"movie_done"] stretchableImageWithLeftCapWidth:20 topCapHeight:15] forState:UIControlStateNormal];
	
	self.singleTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnControlsView:)] autorelease];
	singleTapGestureRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:singleTapGestureRecognizer];
	
	self.rewindButtonLongPressGestureRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnRewindButton:)] autorelease];
	rewindButtonLongPressGestureRecognizer.delaysTouchesBegan = YES;
	[self.rewindButton addGestureRecognizer:rewindButtonLongPressGestureRecognizer];
	
	self.fastForwardButtonLongPressGestureRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnFastForwardButton:)] autorelease];
	fastForwardButtonLongPressGestureRecognizer.delaysTouchesBegan = YES;
	[self.fastForwardButton addGestureRecognizer:fastForwardButtonLongPressGestureRecognizer];
	
	self.slider.value = 0.0f;
	self.upperControlsView.loadingMovie = YES;
	[self loadPlayer];	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
	/*Nothing to do -- we need everything we have. If this view controller has been allocated, it's in use.
	 It gets deallocated when the user is done.*/
}


- (void)viewDidAppear:(BOOL)animated {
	[UIApplication sharedApplication].statusBarHidden = self.originalStatusBarHidden;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;	
}


- (void)viewWillDisappear:(BOOL)animated {
	[self notifyDelegateThatMovieDidFinish];
}


- (void)viewDidDisappear:(BOOL)animated {
	[UIApplication sharedApplication].statusBarHidden = self.originalStatusBarHidden;
	[UIApplication sharedApplication].statusBarStyle = self.originalStatusBarStyle;
}


#pragma mark Hide Controls Timer

- (void)turnOffHideControlsTimer {
	if ([self.hideControlsTimer isValid])
		[self.hideControlsTimer invalidate];
	self.hideControlsTimer = nil;
}


- (void)startHideControlsTimer {
	if (self.hideControlsTimer != nil && [self.hideControlsTimer isValid])
		[self.hideControlsTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:4]];
	else
		self.hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideControlsTimerDidFire:) userInfo:nil repeats:NO];
}


- (void)hideControlsTimerDidFire:(NSTimer *)aTimer {
	[self turnOffHideControlsTimer];
	if (self.loadingMovie || [self playerIsPaused])
		return;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	self.controlsView.alpha = 0.0f;
	[UIView commitAnimations];
}


- (void)showControls {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.05];
	self.controlsView.alpha = 1.0f;
	[UIView commitAnimations];
}


#pragma mark UI Updates

static NSString *timeStringForSeconds(Float64 seconds) {
	NSUInteger minutes = seconds / 60;
	NSUInteger secondsLeftOver = seconds - (minutes * 60);
	return [NSString stringWithFormat:@"%02ld:%02ld", minutes, secondsLeftOver];
}


- (void)updateTimeElapsed {
	self.timeElapsedLabel.text = timeStringForSeconds([self currentTimeInSeconds]);
}


- (void)updateTimeRemaining {
	self.timeRemainingLabel.text = [NSString stringWithFormat:@"-%@", timeStringForSeconds([self timeRemainingInSeconds])];	
}


- (void)updateSlider {
	self.slider.maximumValue = [self durationInSeconds];
	self.slider.value = [self currentTimeInSeconds];
}


- (void)updatePlayPauseButton {
	UIImage *buttonImage = [UIImage imageNamed:@"movie_pause"];
	if ([self playerIsPaused])
		buttonImage = [UIImage imageNamed:@"movie_play"];
	[self.playPauseButton setImage:buttonImage forState:UIControlStateNormal];
}


- (void)updateControls {
	[self updateTimeElapsed];
	[self updateTimeRemaining];
	[self updateSlider];
	[self updatePlayPauseButton];
}


#pragma mark -
#pragma mark Playing Movie

static Float64 secondsWithCMTimeOrZeroIfInvalid(CMTime time) {
	return CMTIME_IS_INVALID(time) ? 0.0f : CMTimeGetSeconds(time);
}


- (Float64)durationInSeconds {
	return secondsWithCMTimeOrZeroIfInvalid(self.movieDuration);
}


- (Float64)currentTimeInSeconds {
	return secondsWithCMTimeOrZeroIfInvalid([self.player currentTime]);
}


- (Float64)timeRemainingInSeconds {
	return [self durationInSeconds] - [self currentTimeInSeconds];
}


- (void)handleDurationDidChange {
	self.movieDuration = self.player.currentItem.asset.duration;
	[self updateControls];
}


- (void)handlePlayerStatusDidChange {
	AVPlayerStatus playerStatus = self.player.status;
	if (playerStatus == AVPlayerStatusReadyToPlay) {
		self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
		[self.view.layer addSublayer:self.playerLayer];
		self.playerLayer.frame = self.view.bounds;
		[self.view bringSubviewToFront:self.controlsView];
		[self.player play];
		self.loadingMovie = NO;
		self.upperControlsView.loadingMovie = NO;
		[self startHideControlsTimer];
	}
}


- (void)handlePlayerError {
	self.movieError = self.player.currentItem.error;
	[self notifyDelegateThatMovieDidFinish];
}


- (void)removeTimeObserver {
	if (self.timeObserver != nil) {
		[self.player removeTimeObserver:self.timeObserver];
		self.timeObserver = nil;
	}
}


- (void)addTimeObserver {
	[self removeTimeObserver];
	self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
		[self updateControls];
		[self checkIfAtEndOfMovie];
	}];
	
}


- (void)loadPlayer {
    if (contentURL) {
        self.player = [[[AVPlayer alloc] initWithURL:self.contentURL] autorelease];
    }
	
    if (theAVAsset) {
        AVPlayerItem *theItem = [AVPlayerItem playerItemWithAsset:theAVAsset];
        self.player = [[[AVPlayer alloc] initWithPlayerItem:theItem] autorelease];
    }
    
	[self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
	[self.player addObserver:self forKeyPath:@"currentItem.asset.duration" options:0 context:nil];
	[self.player addObserver:self forKeyPath:@"currentItem.error" options:0 context:nil];
	self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
	[self addTimeObserver];
}


- (BOOL)playerIsScrubbing {
	return self.rateToRestoreAfterScrubbing > 0.1;
}


- (BOOL)playerHasPlayedToEndOfMovie {
	if (![self playerIsPaused] || [self playerIsScrubbing])
		return NO;
	Float64 currentTime = [self currentTimeInSeconds];
	Float64 duration = [self durationInSeconds];
	return currentTime > 0.01 && duration > 0.01 && ([self currentTimeInSeconds] >= [self durationInSeconds] - 0.1);
}


- (void)checkIfAtEndOfMovie {
	if ([self playerHasPlayedToEndOfMovie])
		[self notifyDelegateThatMovieDidFinish];
}


- (BOOL)playerIsPaused {
	return self.player.rate < 0.01;
}


- (void)playMovie {
	[self.player play];
	[self updateControls];
}


- (void)pauseMovie {
	[self.player pause];
	[self updateControls];
}


#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"status"] && object == self.player)
		[self handlePlayerStatusDidChange];
	else if ([keyPath isEqualToString:@"currentItem.asset.duration"] && object == self.player)
		[self handleDurationDidChange];
	else if ([keyPath isEqualToString:@"currentItem.error"] && object == self.player)
		[self handlePlayerError];
}


#pragma mark Player - Seeking

- (void)seekToSeconds:(Float64)seconds {
	[self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)];
	[self updateControls];
}


typedef enum {
    NGMoviePlayerDirectionRewind,
	NGMoviePlayerDirectionFastForward
} NGMoviePlayerDirection;


- (void)seekRelativeSeconds:(Float64)relativeSeconds direction:(NGMoviePlayerDirection)moviePlayerDirection {
	Float64 currentSeconds = [self currentTimeInSeconds];
	Float64 secondsToSeek;
	if (moviePlayerDirection == NGMoviePlayerDirectionRewind)
		secondsToSeek = MAX(currentSeconds - relativeSeconds, 0.0f);
	else
		secondsToSeek = MIN(currentSeconds + relativeSeconds, [self durationInSeconds]);
	[self seekToSeconds:secondsToSeek];
}
					 
					 
- (void)seekToBeginning {
	[self.player seekToTime:self.player.currentItem.reversePlaybackEndTime];
}


- (void)seekToEnd {
	if ([self durationInSeconds] > 0.01)
		[self.player seekToTime:self.movieDuration];
}


#pragma mark Notifications

- (void)notifyDelegateThatMovieDidFinish {
	[self cleanup];
	if (self.didNotifyDelegate)
		return;
	self.didNotifyDelegate = YES;
	[self.delegate ngMoviePlayerDidFinish:self];
	self.delegate = nil;
}


#pragma mark Rewind and Fast Forward Timers

- (void)stopMoveTimer {
	if (self.moveTimer != nil && [self.moveTimer isValid])
		[self.moveTimer invalidate];
	self.moveTimer = nil;
}


static NSString *NGMoviePlayerDirectionKey = @"NGMoviePlayerDirection";

- (void)moveTimerDidFire:(NSTimer *)timer {
	NGMoviePlayerDirection moviePlayerDirection = [[[timer userInfo] objectForKey:NGMoviePlayerDirectionKey] integerValue];
	[self seekRelativeSeconds:2 direction:moviePlayerDirection];
}


- (void)startMoveTimerWithMoviePlayerDirection:(NGMoviePlayerDirection)moviePlayerDirection {
	[self stopMoveTimer];
	self.moveTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(moveTimerDidFire:) userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:moviePlayerDirection] forKey:NGMoviePlayerDirectionKey] repeats:YES];
}


#pragma mark -
#pragma mark Actions

- (IBAction)donePlayingMovie:(id)sender {
	[self.player pause];
	[self notifyDelegateThatMovieDidFinish];
}


- (IBAction)rewindToBeginning:(id)sender {
	[self startHideControlsTimer];
	[self seekToBeginning];
}


- (IBAction)fastForwardToEnd:(id)sender {
	[self startHideControlsTimer];
	[self seekToEnd];
}


- (IBAction)togglePlaying:(id)sender {
	[self startHideControlsTimer];
	if ([self playerIsPaused])
		[self playMovie];
	else
		[self pauseMovie];
}


- (void)didTapOnControlsView:(id)sender {
	if (self.didNotifyDelegate)
		return;
	[self showControls];
	[self turnOffHideControlsTimer];
	[self startHideControlsTimer];
}


- (IBAction)startScrubbing:(id)sender {
	[self turnOffHideControlsTimer];
	if (self.timeObserver != nil) {
		[self.player removeTimeObserver:self.timeObserver];
		self.timeObserver = nil;
	}
	self.rateToRestoreAfterScrubbing = self.player.rate;
	[self pauseMovie];
}


- (IBAction)stopScrubbing:(id)sender {
	[self startHideControlsTimer];
	[self addTimeObserver];
	if (self.rateToRestoreAfterScrubbing > 0.01f)
		self.player.rate = self.rateToRestoreAfterScrubbing;
	self.rateToRestoreAfterScrubbing = 0.0f;
}


- (IBAction)scrubValueChanged:(id)sender {
	[self seekToSeconds:((UISlider *)sender).value];
}


- (void)handleLongPressOnMoveButtonWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer moviePlayerDirection:(NGMoviePlayerDirection)moviePlayerDirection {
	UIGestureRecognizerState state = gestureRecognizer.state;
	switch (state) {
		case UIGestureRecognizerStateBegan:
			[self startScrubbing:nil];
			[self startMoveTimerWithMoviePlayerDirection:moviePlayerDirection];
			break;
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
			[self stopMoveTimer];
			[self stopScrubbing:nil];
		default:
			break;
	}	
}


- (void)longPressOnRewindButton:(UIGestureRecognizer *)sender {
	[self handleLongPressOnMoveButtonWithGestureRecognizer:sender moviePlayerDirection:NGMoviePlayerDirectionRewind];
}


- (void)longPressOnFastForwardButton:(UIGestureRecognizer *)sender {
	[self handleLongPressOnMoveButtonWithGestureRecognizer:sender moviePlayerDirection:NGMoviePlayerDirectionFastForward];
}


@end

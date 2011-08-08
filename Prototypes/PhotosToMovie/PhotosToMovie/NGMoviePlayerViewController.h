//
//  NGMoviePlayerViewController.h
//  bobcat
//
//  Created by Brent Simmons on 8/14/10.
//  Copyright 2010 NewsGator Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@class NGMoviePlayerViewController;

@protocol NGMoviePlayerDelegate
@required
- (void)ngMoviePlayerDidFinish:(NGMoviePlayerViewController *)ngMoviePlayerViewController;
@end


@class NGMoviePlayerUpperControlsView;

@interface NGMoviePlayerViewController : UIViewController {
@private
	id <NGMoviePlayerDelegate>delegate;
	AVPlayer *player;
	AVPlayerLayer *playerLayer;
	BOOL loadingMovie;
	BOOL originalStatusBarHidden;
	BOOL didNotifyDelegate;
	CMTime movieDuration;
	NGMoviePlayerUpperControlsView *upperControlsView;
	NSError *movieError;
	NSTimer *hideControlsTimer;
	NSTimer *moveTimer;
	NSURL *contentURL;
    AVAsset *theAVAsset;
	UIButton *doneButton;
	UIButton *fastForwardButton;
	UIButton *rewindButton;
	UIButton *playPauseButton;
	UILabel *timeElapsedLabel;
	UILabel *timeRemainingLabel;
	UISlider *slider;
	UIStatusBarStyle originalStatusBarStyle;
	UIView *controlsView;
	float rateToRestoreAfterScrubbing;
	id timeObserver;
	UITapGestureRecognizer *singleTapGestureRecognizer;
	UILongPressGestureRecognizer *rewindButtonLongPressGestureRecognizer;
	UILongPressGestureRecognizer *fastForwardButtonLongPressGestureRecognizer;
}

- (id)initWithContentURL:(NSURL *)aContentURL delegate:(id)aDelegate;


@property (nonatomic, retain) IBOutlet NGMoviePlayerUpperControlsView *upperControlsView;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) IBOutlet UIButton *fastForwardButton;
@property (nonatomic, retain) IBOutlet UIButton *rewindButton;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UILabel *timeElapsedLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeRemainingLabel;
@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet UIView *controlsView;

@property (nonatomic, assign, readonly) BOOL loadingMovie;
@property (nonatomic, retain, readonly) NSError *movieError;


- (IBAction)donePlayingMovie:(id)sender;
- (IBAction)rewindToBeginning:(id)sender;
- (IBAction)fastForwardToEnd:(id)sender;
- (IBAction)togglePlaying:(id)sender;
- (IBAction)startScrubbing:(id)sender;
- (IBAction)stopScrubbing:(id)sender;
- (IBAction)scrubValueChanged:(id)sender;

- (id)initWithAVAsset:(AVAsset *)aAVAsset delegate:(id)aDelegate;
@end




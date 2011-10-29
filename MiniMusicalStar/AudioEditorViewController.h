//
//  AudioEditorViewController.h
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MixPlayerRecorder.h"
#import "Scene.h"
#import "CoverScene.h"
#import "CoverSceneAudio.h"
#import <AVFoundation/AVFoundation.h>

@class Audio;
@interface AudioEditorViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>
{        
    //variables to track the state of the MixPlayer
    bool isRecording;
    bool isPlaying;

    bool stopButtonPressWhenRecordingWarningHasDisplayed;
}

@property (nonatomic, retain) UITableView *trackTableView;
@property (nonatomic, retain) UIImage *recordImage;
@property (nonatomic, retain) UIImage *mutedImage;
@property (nonatomic, retain) UIImage *unmutedImage;
@property (nonatomic, retain) UIImage *trashbinImage;
@property (nonatomic, retain) UIImage *showLyricsImage;
@property (nonatomic, retain) UIImage *playButtonImage;
@property (nonatomic, retain) UIImage *pauseButtonImage;
@property (nonatomic, retain) UIImage *stopButtonImage;

//for the lyrics popover
@property (nonatomic, retain) UIScrollView *lyricsScrollView;
@property (nonatomic, retain) UILabel *lyricsLabel;

@property (nonatomic, retain) MixPlayerRecorder *thePlayer;

@property (nonatomic, retain) Scene *theScene;
@property (nonatomic, retain) CoverScene *theCoverScene;

@property (nonatomic, retain) NSMutableArray *tracksForView;
@property (nonatomic, retain) NSMutableArray *tracksForViewNSURL;
@property (nonatomic, retain) NSMutableArray *arrayOfReplaceableAudios;

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) NSURL *currentRecordingURL;
@property (nonatomic, retain) Audio *currentRecordingAudio;
@property (nonatomic, retain) UILabel *recordingLabel;

@property (nonatomic, retain) UIButton *playPauseButton;

- (id)initWithScene:(Scene *)theScene andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext andPlayPauseButton:(UIButton*)aPlayPauseButton;

- (void)autosaveWhenContextDidChange:(NSNotification*)notification;

//instance methods
- (void)startCoverAudioRecording:(int)indexInConsolidatedAudioTracksArray;
- (void)trashCoverAudio:(int)indexInConsolidatedAudioTracksArray;
- (bool)isRecording;
- (void)playPauseButtonIsPressed;
- (void)giveMePlayPauseButton:(UIButton*)aButton;
- (void)registerNotifications;
- (void)deRegisterFromNSNotifcationCenter;
- (int)getTableViewRow:(UIButton*)sender;

//instance methods for the audio and coveraudio arrays
- (NSArray*)getExportAudioURLs;
- (void)consolidateArrays;
- (void)consolidateReplaceableAudios;

//instance methods for gui
- (void)drawLyricsView;
- (void)loadLyrics:(NSString*)someLyrics;
- (UIScrollView*)createLyricsScrollView;
- (UILabel*)createLyricsLabel;

@end

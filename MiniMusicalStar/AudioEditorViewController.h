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

@interface AudioEditorViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>
{
    UITableView *trackTableView;
    UIImage *recordImage;
    UIImage *recordingImage;
    
    //variables to track the state of the MixPlayer
    bool isRecording;
    bool isPlaying;
    
    //for the lyrics popover
    UIPopoverController *lyricsPopoverController;
    UIScrollView *lyricsScrollView;
    UILabel *lyricsLabel;
    
    //for new lyrics view
    UIView *lyricsView;
    
    //stores a pointer to the play/pause button to the scene editor
    UIButton *playPauseButton;
    
    //variables to store values temporarily when recording covers
    int currentRecordingTrack;
    NSString *lyrics;
    NSURL *currentRecordingNSURL;
    NSString *currentRecordingTrackTitle;
}

@property (nonatomic, retain) UITableView *trackTableView;
@property (nonatomic, retain) UIImage *recordImage;
@property (nonatomic, retain) UIImage *recordingImage;
@property (nonatomic, retain) NSString *lyrics;

//for the lyrics
@property (nonatomic, retain) UIScrollView *lyricsScrollView;
@property (nonatomic, retain) UILabel *lyricsLabel;
@property (nonatomic, retain) UIView *lyricsView;

@property (nonatomic, retain) MixPlayerRecorder *thePlayer;
@property (nonatomic, retain) NSArray *theAudioObjects;
@property (nonatomic, retain) CoverScene *theCoverScene;
@property (nonatomic, retain) NSMutableArray *tracksForView;

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) NSURL *currentRecordingNSURL;
@property (nonatomic, retain) NSString *currentRecordingTrackTitle;

@property (nonatomic, retain) UIButton *playPauseButton;

- (AudioEditorViewController *)initWithScene:(Scene *)theScene andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext andPlayPauseButton:(UIButton*)aPlayPauseButton;

- (void)scrollRowToTopOfTableView:(int)trackNumber;
- (void)prepareLyricsView;

- (void)playButtonIsPressed;
- (void)stopButtonIsPresssed;
- (void)showAndDismissLyricsButtonIsPressed;

- (bool)isRecording;

- (void)giveMePlayPauseButton:(UIButton*)aButton;

- (void)deRegisterFromNSNotifcationCenter;
- (void)registerNotifications;



@end
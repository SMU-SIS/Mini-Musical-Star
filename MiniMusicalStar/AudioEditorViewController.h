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
@class Audio;
@interface AudioEditorViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>
{
    UITableView *trackTableView;
    UIImage *recordImage;
    UIImage *recordingImage;
    UIImage *mutedImage;
    UIImage *unMutedImage;
    UIImage *trashbinImage;
    
    //variables to track the state of the MixPlayer
    bool isRecording;
    bool isPlaying;
    
    //for the lyrics popover
    UIScrollView *lyricsScrollView;
    UILabel *lyricsLabel;
    
    //stores a pointer to the play/pause button to the scene editor
    UIButton *playPauseButton;
    
    //variables to store values temporarily when recording covers
    int currentRecordingTrack;
    NSString *lyrics;
    NSURL *currentRecordingURL;
    Audio *currentRecordingAudio;
}

@property (nonatomic, retain) UITableView *trackTableView;
@property (nonatomic, retain) UIImage *recordImage;
@property (nonatomic, retain) UIImage *recordingImage;
@property (nonatomic, retain) UIImage *mutedImage;
@property (nonatomic, retain) UIImage *unmutedImage;
@property (nonatomic, retain) UIImage *trashbinImage;

@property (nonatomic, retain) NSString *lyrics;

//for the lyrics
@property (nonatomic, retain) UIScrollView *lyricsScrollView;
@property (nonatomic, retain) UILabel *lyricsLabel;

@property (nonatomic, retain) MixPlayerRecorder *thePlayer;
@property (nonatomic, retain) NSArray *theAudioObjects;
@property (nonatomic, retain) CoverScene *theCoverScene;
@property (nonatomic, retain) NSMutableArray *tracksForView;

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) NSURL *currentRecordingURL;
@property (nonatomic, retain) Audio *currentRecordingAudio;

@property (nonatomic, retain) UIButton *playPauseButton;

- (id)initWithScene:(Scene *)theScene andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext andPlayPauseButton:(UIButton*)aPlayPauseButton;

- (void)playButtonIsPressed;
- (void)stopButtonIsPresssed;

- (void)coverAudioRecording;
- (void)trashCoverAudio:(int)indexInConsolidatedAudioTracksArray;

- (bool)isRecording;

- (void)giveMePlayPauseButton:(UIButton*)aButton;

- (void)deRegisterFromNSNotifcationCenter;
- (void)registerNotifications;

- (void)drawLyricsView;
- (CAGradientLayer*)createGradientLayer:(CGRect)frame firstColor:(UIColor*)firstColor andSecondColor:(UIColor*)secondColor;
- (UIScrollView*)createLyricsScrollView;
- (UILabel*)createLyricsLabel;

+ (NSString*)getUniqueFilenameWithoutExt;

- (NSArray*)getExportAudioURLs;



@end

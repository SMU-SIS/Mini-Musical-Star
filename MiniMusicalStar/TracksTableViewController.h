//
//  TracksTableViewController.h
//  MiniMusicalStar
//
//  Created by Tommi on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MixPlayerRecorder.h"
#import "Scene.h"
#import "CoverScene.h"

#define kBringSliderToZero @"kBringSliderToZero"

@protocol TracksTableViewDelegate <NSObject>
@required
- (void)loadLyrics:(NSString*)aLyrics;
@end

@interface TracksTableViewController : UITableViewController
{
    id <TracksTableViewDelegate> delegate;
    
    bool isRecording;
    bool isPlaying;
    int currentRecordingIndex;
}

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) MixPlayerRecorder *thePlayer;
@property (nonatomic, retain) Scene *theScene;
@property (nonatomic, retain) CoverScene *theCoverScene;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) UIButton *playPauseButton;
@property (nonatomic, retain) UILabel *recordingStatusLabel;

@property (nonatomic, retain) NSMutableArray *tracksForView;
@property (nonatomic, retain) NSMutableArray *tracksForViewNSURL;
@property (nonatomic, retain) NSMutableArray *arrayOfReplaceableAudios;

//variables to keep track of recording
@property (nonatomic, retain) NSURL *currentRecordingURL;
@property (nonatomic, retain) Audio *currentRecordingAudio;

//initializer
- (id)initWithScene:(Scene*)aScene andACoverScene:(CoverScene*)aCoverScene andAContext:(NSManagedObjectContext*)aContext andARecordingStatusLabel:(UILabel*)aRecordingStatusLabel;

#pragma mark - instance methods
- (void)updatePlayerStatus:(bool)playingStatus AndRecordingStatus:(bool)recordingStatus;
- (void)reInitPlayer;
- (bool)isRecording;
- (bool)isPlaying;
- (void)recordingIsCompleted;

#pragma mark - instance methods for audio and coveraudio arrays
- (void)consolidateArrays;
- (void)consolidateReplaceableAudios;
- (NSArray*)getExportAudioURLs;

#pragma mark - instance methods for player
- (void)playPauseButtonIsPressed;
- (void)startPlayerPlaying;
- (void)stopPlayerWhenPlaying:(bool)hasReachedEnd;

#pragma mark - NSNotification methods
- (void)registerNotifications;
- (void)deRegisterFromNSNotifcationCenter;

@end
//
//  AudioEditorViewController.h
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackPane.h"
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
    
    int currentRecordingTrack;
    NSString *lyrics;
    
    //for the lyrics popover
    UIPopoverController *lyricsPopoverController;
    UIViewController *lyricsViewController;
    UIScrollView *lyricsScrollView;
    UILabel *lyricsLabel;
}

@property (nonatomic, retain) UITableView *trackTableView;
@property (nonatomic, retain) UIImage *recordImage;
@property (nonatomic, retain) UIImage *recordingImage;
@property (nonatomic, retain) NSString *lyrics;

//for the lyrics popover
@property (nonatomic, retain) UIPopoverController *lyricsPopoverController;
@property (nonatomic, retain) UIViewController *lyricsViewController;
@property (nonatomic, retain) UIScrollView *lyricsScrollView;
@property (nonatomic, retain) UILabel *lyricsLabel;

@property (nonatomic, retain) MixPlayerRecorder *thePlayer;
@property (nonatomic, retain) NSArray *theAudioObjects;
//@property (nonatomic, retain) Scene *theScene;
@property (nonatomic, retain) CoverScene *theCoverScene;
@property (nonatomic, retain) NSMutableArray *tracksForView;

@property (nonatomic, retain) NSManagedObjectContext *context;

- (AudioEditorViewController *)initWithScene:(Scene *)theScene andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext;

- (void)setLyrics:(NSString*)someLyrics;
- (void)removeLyrics;
- (void)displayLyrics;
- (void)dismissLyrics;
- (void)scrollRowToTopOfTableView:(int)trackNumber;

- (IBAction)stopButtonIsPresssed:(UIButton*)stopButton;

@end

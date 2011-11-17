//
//  AudioEditorViewController.h
//  MiniMusicalStar
//
//  Created by Tommi on 16/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TracksTableViewController.h"
#import "LyricsViewController.h"
#import "Scene.h"
#import "CoverScene.h"
#import "CueController.h"

@protocol AudioEditorDelegate <NSObject>
@end

@interface AudioEditorViewController : UIViewController
{
    id <AudioEditorDelegate> delegate;
}

//initializers
- (AudioEditorViewController *)initWithScene:(Scene *)aScene andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext;

//delegate
@property (nonatomic, assign) id delegate;

//IBOutlets
@property (nonatomic, retain) IBOutlet UILabel *recordingStatusLabel;
@property (retain, nonatomic) IBOutlet UIButton *tutorialButton;

//containers
@property (nonatomic, retain) IBOutlet UIView *tracksTableView;
@property (nonatomic, retain) IBOutlet UIView *lyricsView;

//the other two view controllers
@property (nonatomic, retain) TracksTableViewController *tracksTableViewController;
@property (nonatomic, retain) LyricsViewController *lyricsViewController;

//for the cues
@property (retain, nonatomic) CueController *cueController;
@property (retain, nonatomic) UIView *cueView;

@property (nonatomic, retain) Scene *theScene;
@property (nonatomic, retain) CoverScene *theCoverScene;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) UIButton *playPauseButton;

//instance methods
- (void)cueButtonIsPressed:(int)trackIndex;
- (void)removeAndUnloadCueFromView;

//IBAction
- (IBAction) playTutorial:(id)sender;

#pragma mark - instance methods for cues
- (void)setCueButton:(BOOL)shouldShow forTrackIndex:(NSUInteger)trackIndex;

@end

//
//  CrollUIViewController.h
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioEditorViewController.h"
#import "PhotoEditorViewController.h"
#import "Scene.h"
#import "CoverScene.h"
#import "MixPlayerRecorder.h"

@protocol SceneEditPlayerControlDelegate <NSObject>

- (void)togglePlayOrPause;
- (void)setMicVolume:(float)micVolume;
- (void)seekTimeTo:(int)playbackTimeInSeconds;
- (int)totalPlaybackTimeInSeconds;
- (int)currentPlaybackTimeInSeconds;


@end

@interface SceneEditViewController : UIViewController <UIScrollViewDelegate> {
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}

@property (retain, nonatomic) AudioEditorViewController *audioView;
@property (retain, nonatomic) PhotoEditorViewController *photoView;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

@property (retain, nonatomic) IBOutlet UIButton *playPauseButton;
@property (retain, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *songInfoLabel;
@property (retain, nonatomic) IBOutlet UISlider *playPositionSlider;
@property (retain, nonatomic) IBOutlet UISlider *micVolumeSlider;

@property (retain, nonatomic) Scene *theScene;
@property (retain, nonatomic) CoverScene *theCoverScene;
@property (retain, nonatomic) MixPlayerRecorder *thePlayer;

@property (retain, nonatomic) NSManagedObjectContext *context;

- (SceneEditViewController *)initWithScene:(Scene *)aScene andSceneCover:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext;
- (void)loadChildViewControllers;
- (void)setSliderPosition:(int) targetSeconds;

@end

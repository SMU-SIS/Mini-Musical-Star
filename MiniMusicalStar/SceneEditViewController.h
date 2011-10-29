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

@protocol SceneEditViewDelegate <NSObject>
- (NSArray*) getExportAudioURLs;
@end

@interface SceneEditViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate, PhotoEditorViewDelegate> {
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    BOOL transitioning;
    BOOL isReallyStop;
    BOOL isAlertShown;
    
    id <SceneEditViewDelegate> delegate;
    
    IBOutlet UIButton *playPauseButton;
}

@property (nonatomic, assign) id <SceneEditViewDelegate> delegate;

@property (retain, nonatomic) AudioEditorViewController *audioView;
@property (retain, nonatomic) PhotoEditorViewController *photoView;

@property (retain, nonatomic) IBOutlet UIButton *playPauseButton;
@property (retain, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *songInfoLabel;
@property (retain, nonatomic) IBOutlet UISlider *playPositionSlider;
@property (retain, nonatomic) IBOutlet UISlider *micVolumeSlider;
@property (retain, nonatomic) IBOutlet UIView *containerView;
@property (retain, nonatomic) UIBarButtonItem *containerToggleButton;
@property (retain, nonatomic) Scene *theScene;
@property (retain, nonatomic) CoverScene *theCoverScene;
@property (retain, nonatomic) NSManagedObjectContext *context;

- (SceneEditViewController *)initWithScene:(Scene *)aScene andSceneCover:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext;
- (void)loadChildViewControllers;
- (void)setSliderPosition:(int) targetSeconds;
- (void)stopPlayer;
- (NSArray*) getExportAudioURLs;
- (void) playMovie:(NSURL*)filePath;
-(void)drawPlaySlider;
    
@end

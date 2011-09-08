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

@interface SceneEditViewController : UIViewController <UIScrollViewDelegate> {
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

@property (retain, nonatomic) IBOutlet UIButton *playPauseButton;
@property (retain, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *songInfoLabel;
@property (retain, nonatomic) IBOutlet UISlider *playPositionSlider;
@property (retain, nonatomic) IBOutlet UISlider *masterVolumeSlider;

@end

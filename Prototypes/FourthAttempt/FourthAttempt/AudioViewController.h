//
//  FourthAttemptViewController.h
//  FourthAttempt
//
//  Created by Jun Kit Lee on 11/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MixPlayerRecorder.h"

@interface AudioViewController : UIViewController {
    MixPlayerRecorder *player;
}

@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet UISlider *progressSlider;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UIButton *togglePlaybackButton;

- (IBAction)volumeSliderDidMove:(UISlider *)sender;
- (IBAction)segmentedControlDidChange:(UISegmentedControl *)sender;
- (IBAction)togglePlaybackButtonDidPress:(UIButton *)sender;
-(void)updateProgressSliderWithTime:(NSNumber *)elapsedTime;
-(void)stopPlayer;

@end

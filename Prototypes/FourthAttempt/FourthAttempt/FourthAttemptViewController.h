//
//  FourthAttemptViewController.h
//  FourthAttempt
//
//  Created by Jun Kit Lee on 11/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MixPlayerRecorder.h"

@interface FourthAttemptViewController : UIViewController {
    MixPlayerRecorder *player;
}

@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)volumeSliderDidMove:(UISlider *)sender;
- (IBAction)segmentedControlDidChange:(UISegmentedControl *)sender;

@end

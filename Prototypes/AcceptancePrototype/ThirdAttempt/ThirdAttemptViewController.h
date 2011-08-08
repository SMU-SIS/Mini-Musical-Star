//
//  ThirdAttemptViewController.h
//  ThirdAttempt
//
//  Created by Jun Kit on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KaraokeRecorderController.h"
#import "MixPlayback.h"

@interface ThirdAttemptViewController : UIViewController {
    IBOutlet KaraokeRecorderController *karaokeController;
    
    IBOutlet UISlider *micVolumeSlider;
    IBOutlet UISlider *musicVolumeSlider;
    
    NSArray *inputFileURLs;
    
    BOOL isStarted;
    BOOL isPlaying;
    NSString *outputFile;
    MixPlayback *mixPlayer;
    
    IBOutlet UIImageView *slideshowView;
    NSMutableArray *imagesArray;
    int imageCounter;
    UIPopoverController *popover;
    UIImagePickerController *picker;
    
    BOOL originalIsStarted;
    MixPlayback *mixPlayerForOriginal;
    NSArray *inputFileURLsForOriginal;
}

@property (readonly, nonatomic) KaraokeRecorderController *karaokeController;
@property (nonatomic, retain) UISlider *micVolumeSlider;
@property (nonatomic, retain) UISlider *musicVolumeSlider;
@property (nonatomic, retain) MixPlayback *mixPlayer;
@property (nonatomic, retain) UIImageView *slideshowView;
@property (nonatomic, retain) IBOutlet NSArray *imagesArray;
@property (nonatomic, retain) MixPlayback *mixPlayerForOriginal;

-(IBAction)volumeSliderChanged:(UISlider *)sender;
-(IBAction)togglePlayback:(id)sender;
-(IBAction)toggleListenToRecording:(id)sender;
-(IBAction)addImageButtonClicked;
-(IBAction)togglePlayOriginal:(id)sender;

@end

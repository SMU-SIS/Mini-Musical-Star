//
//  ElegantMixerViewController.h
//  ElegantMixer
//
//  Created by Jun Kit on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KaraokeRecorderController.h"

@interface ElegantMixerViewController : UIViewController <MPMediaPickerControllerDelegate> {
    KaraokeRecorderController *karaoke;
}
- (IBAction) showMediaPicker;
@end

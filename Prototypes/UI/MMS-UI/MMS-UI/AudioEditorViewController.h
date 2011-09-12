//
//  AudioEditorViewController.h
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackPane.h"
#import "LyricsViewController.h"

@interface AudioEditorViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>
{
    UITableView *trackTableView;
    UIPopoverController *lyricsPopoverController;
    UIImage *recordImage;
    UIImage *recordingImage;
    
    int currentRecordingTrack;
}

@property (nonatomic, retain) UITableView *trackTableView;
@property (nonatomic, retain) UIPopoverController *lyricsPopoverController;
@property (nonatomic, retain) UIImage *recordImage;
@property (nonatomic, retain) UIImage *recordingImage;

@end

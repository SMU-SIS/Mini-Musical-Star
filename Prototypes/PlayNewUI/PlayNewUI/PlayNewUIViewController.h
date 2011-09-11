//
//  PlayNewUIViewController.h
//  PlayNewUI
//
//  Created by Tommi on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

@interface PlayNewUIViewController : UIViewController 
    <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>
{
    UITableView *trackTableView;
    UIView *trackCellRightPanel;
    UIPopoverController *lyricsPopoverController;
    UIImage *recordImage;
    UIImage *recordingImage;
    
    int currentRecordingTrack;
}

@property (nonatomic, retain) UITableView *trackTableView;
@property (nonatomic, retain) UIView *trackCellRightPanel;
@property (nonatomic, retain) UIPopoverController *lyricsPopoverController;
@property (nonatomic, retain) UIImage *recordImage;
@property (nonatomic, retain) UIImage *recordingImage;

- (IBAction)scrollToX; //to be deleted
- (IBAction)lyricsAppear; //to be deleted
- (IBAction)startRecording; //to be deleted
- (IBAction)stopRecording; //to be deleted

@end

//
//  AudioEditorViewController.h
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

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

- (IBAction)scrollToX; //to be deleted
- (IBAction)lyricsAppear; //to be deleted
- (IBAction)startRecording; //to be deleted
- (IBAction)stopRecording; //to be deleted

@end

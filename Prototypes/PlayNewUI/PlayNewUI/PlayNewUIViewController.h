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
    
    UIImage *recordImage;
    UIImage *recordingImage;
    
    int currentRecordingTrack;
    NSString *lyrics;
    
    //for the lyrics popover
    UIPopoverController *lyricsPopoverController;
    UIViewController *lyricsViewController;
    UIScrollView *lyricsScrollView;
    UILabel *lyricsLabel;

}

@property (nonatomic, retain) UITableView *trackTableView;
@property (nonatomic, retain) UIImage *recordImage;
@property (nonatomic, retain) UIImage *recordingImage;
@property (nonatomic, retain) NSString *lyrics;

@property (nonatomic, retain) UIPopoverController *lyricsPopoverController;
@property (nonatomic, retain) UIViewController *lyricsViewController;
@property (nonatomic, retain) UIScrollView *lyricsScrollView;
@property (nonatomic, retain) UILabel *lyricsLabel;

- (void)setLyrics:(NSString*)someLyrics;
- (void)removeLyrics;
- (void)displayLyrics;
- (void)scrollToTrack:(int)trackNumber;

- (IBAction)scrollToX; //to be deleted
- (IBAction)lyricsAppear; //to be deleted
- (IBAction)startRecording; //to be deleted
- (IBAction)stopRecording; //to be deleted

@end

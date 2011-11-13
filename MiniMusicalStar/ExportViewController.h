//
//  ExportViewController.h
//  MiniMusicalStar
//
//  Created by Tommi on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AddCreditsViewController.h"
#import "Show.h"
#import "Cover.h"
#import "ExportTableViewController.h"
#import "MediaTableViewController.h"
#import "ExportedAsset.h"
#import "YouTubeUploaderViewController.h"
#import "ProgressOverlayViewController.h"

@interface ExportViewController : UIViewController 
    <ProgressOverlayViewDelegate, ExportTableViewDelegate, MediaTableViewDelegate, FacebookUploaderDelegate, YouTubeUploaderDelegate>

@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Cover *theCover;
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) ExportTableViewController *exportTableViewController;
@property (retain, nonatomic) MediaTableViewController *mediaTableViewController;
@property (retain, nonatomic) AddCreditsViewController *addCreditsViewController;

@property (nonatomic, retain) IBOutlet UIButton *addCreditsButton;
@property (retain, nonatomic) IBOutlet UIButton *tutorialButton;

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) FacebookUploaderViewController *facebookUploaderViewController;
@property (nonatomic, retain) YouTubeUploaderViewController *youtubeUploaderViewController;

@property (nonatomic,retain) ProgressOverlayViewController *progressViewController;

- (ExportViewController*)initWithStuff:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext;

- (void) addExportedAsset: (ExportedAsset*) asset;

- (void) showProgressView;
- (void) setProgressViewAtValue:(float)value withAnimation:(BOOL)isAnimated;
- (void) removeProgressView;

- (NSMutableArray*) getTextFieldArray;

- (IBAction) togglePopoverForAddCredits;

- (void) playMovie:(NSURL*)filePath;
- (void) moviePlayBackDidFinish:(NSNotification*)notification;
- (IBAction) playTutorial:(id)sender;

- (IBAction) editTable:(id)sender;

@end

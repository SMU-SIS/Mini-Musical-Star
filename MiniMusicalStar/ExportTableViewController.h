//
//  ExportTableViewController.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 17/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "FacebookUploaderViewController.h"
#import "ExportedAsset.h"

@class Show;
@class ShowDAO;
@class Scene;
@class SceneUtility;
@class Cover;
@class CoverScene;
@class FacebookUploader;
@class YouTubeUploader; 
@class ImageToVideoConverter;
@class MiniMusicalStarUtilities;

@protocol ExportTableViewDelegate <NSObject>
- (void) reloadMediaTable;
@end

@interface ExportTableViewController : UITableViewController

{
    id <ExportTableViewDelegate> delegate;
}

@property (retain, nonatomic) NSArray *musicalArray;
@property (retain, nonatomic) NSArray *scenesArray;
@property (retain, nonatomic) NSMutableArray *exportedAssetsArray;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Cover *theCover;
@property (retain, nonatomic) SceneUtility *theSceneUtility;

@property (nonatomic, assign) id <ExportTableViewDelegate> delegate;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIBarButtonItem *uploadBarButtonItem;
@property (retain, nonatomic) NSMutableArray *tempMusicalContainer;
@property (retain, nonatomic) UIImage *facebookUploadImage;
@property (retain, nonatomic) UIImage *youtubeUploadImage;
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) FacebookUploaderViewController *facebookUploaderViewController;

- (id)initWithStyle:(UITableViewStyle)style:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext;
- (void) generateMusical;
- (void) prepareMusicalNotification;
- (void) processExportSession: (AVMutableComposition*) composition:(NSURL*)videoFileURL:(NSURL*)creditsFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSString*) state;
-(void) sessionExport: (AVMutableComposition*) composition: (NSURL*)videoFileURL: (NSURL*)creditsFileURL: (NSURL*)outputFileURL: (NSIndexPath*) indexPath: (NSString*) state;
- (void)exportScene:(Scene*) scene:(CoverScene*) coverScene: (NSIndexPath*) indexPath;
- (void)exportMusical:(Show*)show;

- (void) removeFileAtPath: (NSURL*) filePath;
- (void) exportCompleted: (NSURL*) videoFileURL: (NSURL*) creditsFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSTimer*) progressBarLoader: (NSString*) state;
- (void) allScenesExportedNotificationSender;
- (int)getTableViewRow:(UIButton*)sender;
- (void)killFacebookUploaderViewController;

@end

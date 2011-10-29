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

@interface ExportTableViewController : UITableViewController
{
    FacebookUploader *mmsFacebook;
}

@property (retain, nonatomic) NSArray *musicalArray;
@property (retain, nonatomic) NSArray *scenesArray;
@property (retain, nonatomic) NSMutableArray *exportedFilesArray;
@property (retain, nonatomic) NSMutableArray *exportedFileNamesArray;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Cover *theCover;
@property (retain, nonatomic) SceneUtility *theSceneUtility;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIBarButtonItem *uploadBarButtonItem;
@property (nonatomic, retain) FacebookUploader *mmsFacebook;
@property (retain, nonatomic) NSMutableArray *tempMusicalContainer;
@property (retain, nonatomic) UIImage *facebookUploadImage;
@property (retain, nonatomic) UIImage *youtubeUploadImage;

- (id)initWithStyle:(UITableViewStyle)style:(Show*)theShow:(Cover*)cover;
- (void) generateMusical;
- (void) prepareMusicalNotification;
- (void)uploadToFacebook;
- (void)generateMusical;
- (void)uploadToFacebook;
- (void) processExportSession: (AVMutableComposition*) composition:(NSURL*)videoFileURL:(NSURL*)creditsFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSString*) state;
-(void) sessionExport: (AVMutableComposition*) composition: (NSURL*)videoFileURL: (NSURL*)creditsFileURL: (NSURL*)outputFileURL: (NSIndexPath*) indexPath: (NSString*) state;
- (void)exportScene:(Scene*) scene:(CoverScene*) coverScene: (NSIndexPath*) indexPath;
- (void)exportMusical:(Show*)show;
- (void) playMovie:(NSURL*)filePath;
- (void) moviePlayBackDidFinish:(NSNotification*)notification;
- (void) removeFileAtPath: (NSURL*) filePath;
- (void) exportCompleted: (NSURL*) videoFileURL: (NSURL*) creditsFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSTimer*) progressBarLoader: (NSString*) state;
- (void) allScenesExportedNotificationSender;

@end

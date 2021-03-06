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
#import <AssetsLibrary/AssetsLibrary.h>
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
- (NSMutableArray *) getTextFieldArray;
- (void) showProgressView;
- (void) setProgressViewAtValue:(float)value withAnimation:(BOOL)isAnimated;
@end

@interface ExportTableViewController : UITableViewController

{
    id <ExportTableViewDelegate> delegate;
}

@property (retain, nonatomic) NSArray *musicalArray;
@property (retain, nonatomic) NSMutableArray *scenesArray;
@property (retain, nonatomic) NSMutableArray *exportedAssetsArray;
@property (retain, nonatomic) NSMutableArray *musicalAudioMappings;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Scene *theScene;
@property (retain, nonatomic) Cover *theCover;
@property (retain, nonatomic) SceneUtility *theSceneUtility;

@property (nonatomic, assign) id <ExportTableViewDelegate> delegate;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIBarButtonItem *uploadBarButtonItem;
@property (retain, nonatomic) NSMutableArray *tempMusicalContainer;

@property(retain,nonatomic) NSMutableArray *exportedAssetOrder;
@property(retain,nonatomic) AVAssetExportSession *exportSessionObject;

@property (retain, nonatomic) NSManagedObjectContext *context;

- (id)initWithStyle:(UITableViewStyle)style:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext;
- (void) generateMusical;
- (void) prepareMusicalNotification;

-(void) sessionExport: (AVMutableComposition*) composition: (NSURL*)videoFileURL: (NSURL*)creditsFileURL: (NSURL*)outputFileURL: (NSIndexPath*) indexPath: (NSString*) state;
- (void)exportScene:(Scene*) scene:(CoverScene*) coverScene: (NSIndexPath*) indexPath;
- (void)exportMusical:(Show*)show;

- (void) removeFileAtPath: (NSURL*) filePath;

- (void) processExportSessionWithComposition:(AVMutableComposition*)composition andVideoComposition:(AVMutableVideoComposition*)videoComposition withOutputFilePath:(NSURL*)outputFileURL andVideoFilePath:(NSURL*)videoFileURL forMusical:(BOOL)isMusical;
- (void) saveExportedAssetAt:(NSURL*)outputFileURL andDeleteVideoFile:(NSURL*)videoFileURL forMusical:(BOOL)isMusical isSceneAppend:(BOOL)isSceneAppend;
-(void)processImageAndAudioAppendingToVideoWithImagesArray:(NSArray*)imagesArray andSortedPicturesTimingArray:(NSMutableArray*)sortedTimingsArray andAudioFilePaths:(NSArray*) audioExportURLs forMusical:(BOOL)isMusical;
-(AVMutableVideoComposition*) getVideoCompositionWithCustomAnimationsToComposition:(AVMutableComposition*)composition andSortedTimingsArrayForKensBurn:(NSMutableArray*)sortedTimingsArray withVideoAsset:(AVAsset*)videoAsset ofVideoSize:(CGSize)videoSize;

- (void)refreshProgressBar:(NSTimer*) aTimer;

- (int)getTableViewRow:(UIButton*)sender;

@end

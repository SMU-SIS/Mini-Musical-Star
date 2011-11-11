//
//  ExportTableViewController.m
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 17/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExportTableViewController.h"
#import "ImageToVideoConverter.h"
#import "Show.h"
#import "ShowDAO.h"
#import "SceneUtility.h"
#import "Cover.h"
#import "AudioEditorViewController.h"
#import "ImageToVideoConverter.h"
#import "MiniMusicalStarUtilities.h"
#import "ExportedAsset.h"
#import "DSActivityView.h"
#import "KensBurnAnimation.h"
#import "CustomVideoAnimations.h"

@implementation ExportTableViewController

@synthesize theShow;
@synthesize theScene;
@synthesize theCover;
@synthesize theSceneUtility;
@synthesize timer;
@synthesize musicalArray;
@synthesize musicalAudioMappings;
@synthesize scenesArray;
@synthesize exportedAssetsArray;
@synthesize uploadBarButtonItem;
@synthesize tempMusicalContainer;
@synthesize context;
@synthesize delegate;

-(void)dealloc
{
    [delegate release];
    [tempMusicalContainer release];
    [musicalArray release];
    [scenesArray release];
    [exportedAssetsArray release];
    [timer release];
    [theCover release];
    [theSceneUtility release];
    [theScene release];
    [theShow release];
    [musicalAudioMappings release];
    [context release];
    
    [super dealloc];
}


- (id)initWithStyle:(UITableViewStyle)style:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext
{
    self = [super initWithStyle:style];
    if (self) {
        self.theShow = show;
        self.theCover = cover;
        self.musicalArray = [NSArray arrayWithObject:show];
        self.scenesArray = [show.scenes allValues];
        self.musicalAudioMappings = [[NSMutableArray alloc] initWithCapacity:0];
        self.exportedAssetsArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.tempMusicalContainer = [[NSMutableArray alloc] init];
        self.context = aContext;
        [self prepareMusicalNotification];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 100.0;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0){
        return @"Export Musicals";
    }else if (section==1){
        return @"Export Scenes";
    }
    return nil;
}

- (void) processExportSessionWithComposition:(AVMutableComposition*)composition andVideoComposition:(AVMutableVideoComposition*)videoComposition withOutputFilePath:(NSURL*)outputFileURL andVideoFilePath:(NSURL*)videoFileURL forMusical:(BOOL)isMusical
{
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:composition];
    
    if ([compatiblePresets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        if(videoComposition){
            exportSession.videoComposition = videoComposition;
        }
        
        exportSession.outputURL = outputFileURL;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        exportSession.timeRange = CMTimeRangeMake(kCMTimeZero,CMTimeAdd(composition.duration,CMTimeMake(11,1)));
        
        CMTimeRangeShow(exportSession.timeRange);
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export Completed");
                    [self saveExportedAssetAt:outputFileURL andDeleteVideoFile:videoFileURL forMusical:isMusical];
                    break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                default:
                    break;
            }
            [exportSession release];
            
        }];
    }
}
- (void) saveExportedAssetAt:(NSURL*)outputFileURL andDeleteVideoFile:(NSURL*)videoFileURL forMusical:(BOOL)isMusical
{
    //save the URL into a new model
    ExportedAsset *newAsset = [NSEntityDescription insertNewObjectForEntityForName:@"ExportedAsset" inManagedObjectContext:self.context];
    newAsset.exportPath = [outputFileURL absoluteString];
    newAsset.originalHash = theCover.originalHash;
    newAsset.exportHash = [outputFileURL lastPathComponent];
    newAsset.dateCreated = [NSDate date];
    
    if (!isMusical){
        newAsset.isFullShow = NO;
        newAsset.title = self.theScene.title;
    }else{
        newAsset.isFullShow = [NSNumber numberWithInt:1];
        newAsset.title = theShow.title;
    }
    
    [self.context save:nil];
    [self.exportedAssetsArray addObject:newAsset];
    [self removeFileAtPath:videoFileURL];
    
    [self.delegate reloadMediaTable];
    [self.tableView reloadData];
    [DSBezelActivityView removeViewAnimated:YES];
    
}

- (void) removeFileAtPath: (NSURL*) filePath
{
    [[NSFileManager defaultManager] removeItemAtURL:filePath error: NULL];
}

- (void)refreshProgressBar:(NSTimer*) aTimer
{
    UIProgressView *prog = [aTimer.userInfo objectAtIndex:0];
    AVAssetExportSession *exportSession = [aTimer.userInfo objectAtIndex:1];
    //    NSLog(@"export timer : %f",exportSession.progress);
    [prog setProgress: exportSession.progress];
    
}


-(AVMutableVideoComposition*) getVideoCompositionWithCustomAnimationsToComposition:(AVMutableComposition*)composition andSortedTimingsArrayForKensBurn:(NSMutableArray*)sortedTimingsArray withVideoAsset:(AVAsset*)videoAsset ofVideoSize:(CGSize)videoSize
{
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd([composition duration], CMTimeMake(11, 1)));
    AVAssetTrack *videoTrack = [[composition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];    
    passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
    passThroughInstruction.enablePostProcessing = YES;
    
    videoComposition.instructions = [NSArray arrayWithObject:passThroughInstruction];       
    videoComposition.frameDuration = CMTimeMake(1, 30); 
    videoComposition.renderSize = videoSize;
    videoComposition.renderScale = 1.0;
    
    [composition insertEmptyTimeRange:CMTimeRangeMake(composition.duration,CMTimeMake(11,1))];
    
    CALayer *animationLayer = [CALayer layer];
    animationLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height);
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    
    parentLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height);
    parentLayer.anchorPoint =  CGPointMake(0, 0);
    parentLayer.position = CGPointMake(0, 0);
    
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    videoLayer.anchorPoint =  CGPointMake(0.5, 0.5);
    videoLayer.position = CGPointMake(CGRectGetMidX(parentLayer.bounds), CGRectGetMidY(parentLayer.bounds));
    [parentLayer addSublayer:animationLayer];
    animationLayer.anchorPoint =  CGPointMake(0.5, 0.5);
    animationLayer.position = CGPointMake(CGRectGetMidX(parentLayer.bounds),0);
    
    NSMutableArray *textFieldArray = [delegate getTextFieldArray];
    [CustomVideoAnimations addTextAnimationLayersToLayer:animationLayer withTextArray:textFieldArray forVideoSize:videoSize];
    
    [animationLayer setOpacity: 0.0];
    
    CABasicAnimation *appearAnimation = [CustomVideoAnimations getAppearAnimationAtTime:CMTimeGetSeconds(composition.duration) withDuration: 1.0];
    [animationLayer addAnimation:appearAnimation forKey:nil];
    
    CABasicAnimation *scrollAnimation = [CustomVideoAnimations getScrollAnimationAtTime:CMTimeGetSeconds(composition.duration) withDuration:10.0];
    [animationLayer addAnimation:scrollAnimation forKey:nil];
    
    CABasicAnimation *fadeAnimation = [CustomVideoAnimations getFadeAnimationAtTime:CMTimeGetSeconds(composition.duration) withDuration:0.1];
    [videoLayer addAnimation:fadeAnimation forKey:nil];
    
    Float64 videoLength = CMTimeGetSeconds(videoAsset.duration);
    
    KensBurnAnimation *kbAnim = [[KensBurnAnimation alloc] init];
    [kbAnim addKensBurnAnimationToLayer:videoLayer withTimingsArray:sortedTimingsArray overDuration:videoLength];
    
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    return videoComposition;
}

-(void)processImageAndAudioAppendingToVideoWithImagesArray:(NSArray*)imagesArray andSortedPicturesTimingArray:(NSMutableArray*)sortedTimingsArray andAudioFilePaths:(NSArray*) audioExportURLs forMusical:(BOOL)isMusical
{
    __block NSError *error = nil;
    CGSize size = CGSizeMake(640, 480);
    NSString *videoFilename = [@"/vid_" stringByAppendingString:[[MiniMusicalStarUtilities getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *videoFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:videoFilename]];
    
    NSString *exportFilename = [@"/scene_" stringByAppendingString:[[MiniMusicalStarUtilities getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *outputFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:exportFilename]];
    
    //write image to video conversion
    [ImageToVideoConverter createImagesConvertedToVideo:sortedTimingsArray :imagesArray :videoFileURL :size];
    
    //now i will combine track and video
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoFileURL options:nil];
    
    __block AVMutableCompositionTrack *compositionAudioTrack = NULL;
    [audioExportURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *audioURL = (NSURL*)obj;
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioURL options:nil];
        
        compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        //if it is a musical, check ordering
        if(isMusical){
            CMTime startTime = CMTimeMake([[musicalAudioMappings objectAtIndex:idx] floatValue] *1000000, 1000000);
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,audioAsset.duration) 
                                           ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] 
                                            atTime:startTime
                                             error:&error];
            
        }else{
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,audioAsset.duration) 
                                       ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] 
                                        atTime:kCMTimeZero
                                         error:&error];
        }
    }];
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAsset.duration) 
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0] 
                                    atTime:kCMTimeZero error:&error];
    
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    CGSize videoSize = CGSizeApplyAffineTransform(clipVideoTrack.naturalSize, clipVideoTrack.preferredTransform);
    videoSize.width = fabs(videoSize.width);
    videoSize.height = fabs(videoSize.height);
    
    AVMutableVideoComposition *videoComposition = [self getVideoCompositionWithCustomAnimationsToComposition:composition andSortedTimingsArrayForKensBurn:sortedTimingsArray withVideoAsset:videoAsset ofVideoSize:videoSize];
    //session export
    [self processExportSessionWithComposition:composition andVideoComposition:videoComposition withOutputFilePath:outputFileURL andVideoFilePath:videoFileURL forMusical:isMusical];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0){
        return [musicalArray count];
    }else if (section == 1){
        return [scenesArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    
    // Configure the cell...
    if(indexPath.section ==0){
        Show *show = [musicalArray objectAtIndex:0];
        cell.imageView.image = show.coverPicture;
        cell.textLabel.text = show.title;
        
    }else if(indexPath.section ==1){
        Scene *scene = [scenesArray objectAtIndex:indexPath.row];
        cell.imageView.image = scene.coverPicture;
        cell.textLabel.text = scene.title;
        
    }else{
        //use the ExportedAsset model here
        ExportedAsset *theAsset = [exportedAssetsArray objectAtIndex:indexPath.row];
        cell.textLabel.text =  theAsset.title;
        
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    
    if (section == 0) {
        headerLabel.text = @"Export Musical";
    } else if (section == 1) {
        headerLabel.text = @"Export Scenes";
    }
    
	[customView addSubview:headerLabel];
    
	return customView;
}

#pragma mark - Table view delegate

- (void)exportScene:(Scene*) scene:(CoverScene*) coverScene: (NSIndexPath*) indexPath
{
    theSceneUtility = [[SceneUtility alloc] initWithSceneAndCoverScene: self.theScene:coverScene];
    
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Exporting your scene... WAIT OK!? otherwise your ipad might EXPLODE...BOOM!"];
    
    [self processImageAndAudioAppendingToVideoWithImagesArray:[theSceneUtility getMergedImagesArray] andSortedPicturesTimingArray:[self.theScene getOrderedPictureTimingArray] andAudioFilePaths:[theSceneUtility getExportAudioURLs] forMusical:NO];
    
}
- (void)exportMusical:(Show*)show
{
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Exporting your musical... WAIT OK!? otherwise your ipad might EXPLODE...BOOM!"];
    
    //get the fully appended images array and picturetimings dict
    NSMutableArray *musicalImagesArray = [[NSMutableArray alloc] initWithCapacity:0];
    //get an appendable array for audioExportURLS
    NSMutableArray *musicalAudioURLs = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *musicalImagesPicturesTimingsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    CMTime previousAssetDuration = kCMTimeZero;
    int audioOrderCount = 1;
    [self.musicalAudioMappings removeAllObjects];
    for (id obj in scenesArray){
        Scene *scene = (Scene*)obj;
        CoverScene *coverScene = [theCover coverSceneForSceneHash:scene.hash];
        theSceneUtility = [[SceneUtility alloc] initWithSceneAndCoverScene: scene:coverScene];
        
        [musicalImagesArray addObjectsFromArray:theSceneUtility.getMergedImagesArray];
        
        if(CMTimeCompare(previousAssetDuration, kCMTimeZero) != 0){
            NSMutableArray *transferredArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0 ; i<scene.getOrderedPictureTimingArray.count; i++){
                int timing = [[scene.getOrderedPictureTimingArray objectAtIndex:i] intValue];
                timing += [[NSNumber numberWithFloat:CMTimeGetSeconds(previousAssetDuration)] intValue];
                NSNumber *newTiming =[NSNumber numberWithInt:timing];
                [transferredArray addObject:newTiming];
            }
            [musicalImagesPicturesTimingsArray addObjectsFromArray:transferredArray];
            
        }else{
            [musicalImagesPicturesTimingsArray addObjectsFromArray:[scene getOrderedPictureTimingArray]];
        }
        
        [musicalAudioURLs addObjectsFromArray:theSceneUtility.getExportAudioURLs];
        
        //map audio sequences to scene order
        for (id obj in theSceneUtility.getExportAudioURLs)
        {
            [self.musicalAudioMappings addObject:[NSNumber numberWithFloat: CMTimeGetSeconds(previousAssetDuration)]];
        }
        
        
        //get duration of previous scene measured with duration of first audio file
        NSURL *firstAudioURL = [theSceneUtility.getExportAudioURLs objectAtIndex:0];
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:firstAudioURL options:nil];
        previousAssetDuration = audioAsset.duration;
        
        audioOrderCount += 1;
    };
    [self processImageAndAudioAppendingToVideoWithImagesArray:musicalImagesArray andSortedPicturesTimingArray:musicalImagesPicturesTimingsArray andAudioFilePaths:musicalAudioURLs forMusical:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        [self exportMusical:[musicalArray objectAtIndex:0]];
    }else if(indexPath.section == 1){
        Scene *selectedScene = [scenesArray objectAtIndex:indexPath.row];
        CoverScene *selectedCoverScene = [theCover coverSceneForSceneHash:selectedScene.hash];
        self.theScene = selectedScene;
        [self exportScene :nil:selectedCoverScene:indexPath];
    }
    
}

@end

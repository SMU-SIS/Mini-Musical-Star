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

@implementation ExportTableViewController

@synthesize theShow;
@synthesize theCover;
@synthesize theSceneUtility;
@synthesize timer;
@synthesize musicalArray;
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
    [theSceneUtility release];
    [theShow release];
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
        self.exportedAssetsArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.tempMusicalContainer = [[NSMutableArray alloc] init];
        self.context = aContext;
        [self prepareMusicalNotification];
    }
    return self;
}

- (void) generateMusical{
    //now i will combine track and video
    __block AVMutableComposition *composition = [AVMutableComposition composition];
    [tempMusicalContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AVURLAsset *videoAsset = [[AVURLAsset alloc]initWithURL:obj options:nil];
//        NSLog(@"here : %@",[NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:obj]]);
        CMTime startTime = kCMTimeZero;
        if(idx > 0){
            AVURLAsset *previousVideoAsset = [[AVURLAsset alloc]initWithURL:[tempMusicalContainer objectAtIndex:idx-1] options:nil];
            startTime = previousVideoAsset.duration;
        }
        [composition insertTimeRange: CMTimeRangeMake(kCMTimeZero,videoAsset.duration)
                             ofAsset:videoAsset atTime:composition.duration error:nil];
        
    }];
    
    //write credits to video
    NSArray *creditsList = [NSArray arrayWithObjects:@"Drawn With CoreText",@"Made by Adrian!", nil];
    NSString *creditsFilename = [@"/credits_" stringByAppendingString:[[MiniMusicalStarUtilities getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *creditsFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:creditsFilename]];
    [ImageToVideoConverter createTextConvertedToVideo:creditsList:creditsFileURL :CGSizeMake(640,480)];
    //append credits
    AVURLAsset *creditsAsset = [AVURLAsset URLAssetWithURL:creditsFileURL options:nil];
    [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero,creditsAsset.duration) 
                         ofAsset:creditsAsset
                          atTime:composition.duration
                           error:nil];
    //add brand asset path
    NSString *brandAssetPath =[[NSBundle mainBundle] pathForResource:@"lastclip" ofType:@"mov"];
    AVURLAsset *brandAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:brandAssetPath] options:nil];
    [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero,brandAsset.duration) 
                         ofAsset:brandAsset
                          atTime:composition.duration
                           error:nil];
    
    //session export
    //draw the progress bar
    CGRect progressBarFrame;
    progressBarFrame.size.width = 300;
    progressBarFrame.size.height = 300;
    progressBarFrame.origin.x = 500;
    progressBarFrame.origin.y = 25;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.view cellForRowAtIndexPath:indexPath];
    UIProgressView *prog = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    prog.frame= progressBarFrame;
    [cell.contentView addSubview:prog];
    [prog setProgress:0];

    NSString *exportFilename = [@"/musical_" stringByAppendingString:[[MiniMusicalStarUtilities getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *outputFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:exportFilename]];
    [self processExportSession: nil:composition :nil :nil:creditsFileURL:outputFileURL:prog:@"musical appending"];

}

- (void) prepareMusicalNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generateMusical) name:@"scenesFinished" object:nil];
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

- (void) processExportSession: (Scene*) scene :(AVMutableComposition*) composition :(AVMutableVideoComposition*)videoComposition :(NSURL*)videoFileURL:(NSURL*)creditsFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSString*) state
{
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:composition];
    
    if ([compatiblePresets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        
        //wire the videoComposition
        if(videoComposition){
            exportSession.videoComposition = videoComposition;
        }
        
        exportSession.outputURL = outputFileURL;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        exportSession.timeRange = CMTimeRangeMake(kCMTimeZero,composition.duration);
        
        NSArray *userInfo = [NSArray arrayWithObjects:prog,exportSession,nil];
        NSTimer *progressBarLoader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshProgressBar:) userInfo:userInfo repeats:YES];
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export Completed");
                    [self exportCompleted: scene: videoFileURL:creditsFileURL:outputFileURL:prog:progressBarLoader:state];
                    break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                default:
                    break;
            }
            [prog release];
            [exportSession release];

        }];
    }
}

-(void) sessionExport: (Scene*)scene: (AVMutableComposition*) composition: (AVMutableVideoComposition*) videoComposition : (NSURL*)videoFileURL: (NSURL*)creditsFileURL: (NSURL*)outputFileURL: (NSIndexPath*) indexPath: (NSString*) state
{
    
    //draw the progress bar
    CGRect progressBarFrame;
    progressBarFrame.size.width = 300;
    progressBarFrame.size.height = 300;
    progressBarFrame.origin.x = 400;
    progressBarFrame.origin.y = 25;
    
    UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.view cellForRowAtIndexPath:indexPath];
    UIProgressView *prog = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    prog.frame= progressBarFrame;
    [cell.contentView addSubview:prog];
    
    [self processExportSession :scene :composition :videoComposition :videoFileURL:creditsFileURL:outputFileURL:prog:state];
    
}
- (void) exportCompleted: (Scene*) scene :(NSURL*) videoFileURL: (NSURL*) creditsFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSTimer*) progressBarLoader: (NSString*) state
{
    if ([state isEqualToString: @"scene only"]){
        //save the URL into a new model
        ExportedAsset *newAsset = [NSEntityDescription insertNewObjectForEntityForName:@"ExportedAsset" inManagedObjectContext:self.context];
        newAsset.isFullShow = NO;
        newAsset.exportPath = [outputFileURL absoluteString];
        newAsset.title = scene.title;
        newAsset.originalHash = theCover.originalHash;
        newAsset.exportHash = [outputFileURL lastPathComponent];
        newAsset.dateCreated = [NSDate date];
        
        [self.context save:nil];
        
        [self.exportedAssetsArray addObject:newAsset];
        
        [self removeFileAtPath:videoFileURL];
        [self removeFileAtPath:creditsFileURL];
    }else if ([state isEqualToString: @"scenes for musical"]){
        [self.tempMusicalContainer addObject:outputFileURL];
        [self allScenesExportedNotificationSender];
        [self removeFileAtPath:videoFileURL];
    }else if ([state isEqualToString: @"musical appending"]){
        //save the URL into a new model
        ExportedAsset *newAsset = [NSEntityDescription insertNewObjectForEntityForName:@"ExportedAsset" inManagedObjectContext:self.context];
        newAsset.isFullShow = [NSNumber numberWithInt:1];
        newAsset.exportPath = [outputFileURL absoluteString];
        newAsset.title = theShow.title;
        newAsset.originalHash = theCover.originalHash;
        newAsset.exportHash = [outputFileURL lastPathComponent];
        newAsset.dateCreated = [NSDate date];
        
        [self.context save:nil];
        
        [self.exportedAssetsArray addObject:newAsset];
        
        [tempMusicalContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self removeFileAtPath:obj];
        }];
        [self removeFileAtPath:creditsFileURL];
        [tempMusicalContainer removeAllObjects];
    }
    [prog removeFromSuperview];
    [progressBarLoader invalidate];
    [self.delegate reloadMediaTable];
    [self.tableView reloadData];
    [DSBezelActivityView removeViewAnimated:YES];
    
//    //temp only, trying CALayer
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,640,480)];
//    
//    [self.view addSubview:view];
//    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:[@"Documents" stringByAppendingPathComponent:@"coverflow1.png"]]];
//    //temp only, trying CALayer
//    UIImageView *view = [[UIImageView alloc] initWithImage:image];
//    
//    self.view = view;
//    
//
//    view.frame = CGRectMake(320,0,640,480); // some frame that zooms in on the image;
//
//    KensBurner *kensBurner = [[KensBurner alloc] initWithImageView:self.view];
//    [kensBurner startAnimation];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:3];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
//    view.frame = CGRectMake(100.0,100.0,640,480);// original frame
//    view.center = CGPointMake(0,0);// original centerpoint
    
//    [UIView commitAnimations];
    
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

- (void) allScenesExportedNotificationSender
{
    if ([tempMusicalContainer count] == [scenesArray count]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scenesFinished" object:self];
    }
    
}

-(void)generateSceneVideo: (Scene*) theScene: (NSArray*) imagesArray:(NSArray*) audioExportURLs:(NSIndexPath*) indexPath: (NSString*) state
{
    __block NSError *error = nil;
    CGSize size = CGSizeMake(640, 480);
    NSString *videoFilename = [@"/vid_" stringByAppendingString:[[MiniMusicalStarUtilities getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *videoFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:videoFilename]];
    
    NSString *exportFilename = [@"/scene_" stringByAppendingString:[[MiniMusicalStarUtilities getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *outputFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:exportFilename]];
    //write image to video conversion
    [ImageToVideoConverter createImagesConvertedToVideo:theScene :imagesArray :videoFileURL :size];
    
    
    //now i will combine track and video
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoFileURL options:nil];
    
    __block AVMutableCompositionTrack *compositionAudioTrack = NULL;
    
    [audioExportURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *audioURL = (NSURL*)obj;
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioURL options:nil];
        
        compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,audioAsset.duration) 
                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] 
                                         atTime:kCMTimeZero
                                          error:&error];
         CMTimeRangeShow(CMTimeRangeMake(kCMTimeZero,audioAsset.duration));
    }];
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAsset.duration) 
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0] 
                                    atTime:kCMTimeZero error:&error];

    NSArray *creditsList = [NSArray arrayWithObjects:@"Drawn With CoreText",@"Made by Adrian!", nil];
    NSString *creditsFilename = [@"/credits_" stringByAppendingString:[[MiniMusicalStarUtilities getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *creditsFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:creditsFilename]];
    if([state isEqualToString: @"scene only"]){
        //write credits to video
        [ImageToVideoConverter createTextConvertedToVideo:creditsList:creditsFileURL :size];
        //append credits
        AVURLAsset *creditsAsset = [AVURLAsset URLAssetWithURL:creditsFileURL options:nil];
        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero,creditsAsset.duration) 
                             ofAsset:creditsAsset
                              atTime:composition.duration
                               error:&error];        
        //append made by minimusicalstar
        NSString *brandAssetPath =[[NSBundle mainBundle] pathForResource:@"lastclip" ofType:@"mov"];
        AVURLAsset *brandAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:brandAssetPath] options:nil];
//        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero,brandAsset.duration) 
//                         ofAsset:brandAsset
//                         atTime:composition.duration
//                           error:&error];
    }
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    CGSize videoSize = CGSizeApplyAffineTransform(clipVideoTrack.naturalSize, clipVideoTrack.preferredTransform);
    videoSize.width = fabs(videoSize.width);
    videoSize.height = fabs(videoSize.height);
    
    CMTime titleDuration = CMTimeMakeWithSeconds(5, 600);
    CMTimeRange titleRange = CMTimeRangeMake(kCMTimeZero, titleDuration);
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);
    AVAssetTrack *videoTrack = [[composition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];    
    passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
    passThroughInstruction.enablePostProcessing = YES;
    
    videoComposition.instructions = [NSArray arrayWithObject:passThroughInstruction];       
    videoComposition.frameDuration = CMTimeMake(1, 30); 
    videoComposition.renderSize = videoSize;
    videoComposition.renderScale = 1.0;

    CALayer *animationLayer = [CALayer layer];
    animationLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height);
    

//    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CGAffineTransform zoomIn = CGAffineTransformMakeScale(1.2, 0.8);
    CGAffineTransform moveRight = CGAffineTransformMakeTranslation(50, 80);
    CGAffineTransform combo1 = CGAffineTransformConcat(zoomIn, moveRight);
    
//    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(combo1)];
    fadeAnimation.additive = NO;
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
    fadeAnimation.duration = 5;
    fadeAnimation.fillMode = kCAFillModeBoth;
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
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
    animationLayer.position = CGPointMake(CGRectGetMidX(parentLayer.bounds), CGRectGetMidY(parentLayer.bounds));
    
    [videoLayer addAnimation:fadeAnimation forKey:nil];
    
    
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    //session export
    [self sessionExport: theScene:composition:videoComposition:videoFileURL:creditsFileURL:outputFileURL:indexPath:state];

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
        
        //cell.textLabel.backgroundColor = [UIColor whiteColor];
        
        /*
         Instructions for use:
         
         ExportedAsset *foo = [NSEntityDescription insertNewObjectForEntityForName: @"ExportedAsset" inManagedObjectContext: context];
         foo.title = @"Blah blah blah";
         ...
         NSError *error;
         [context save: error];
         
         if (error)
         {
         //handle the saving error
         }
         */
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)exportScene:(Scene*) scene:(CoverScene*) coverScene: (NSIndexPath*) indexPath
{
    theSceneUtility = [[SceneUtility alloc] initWithSceneAndCoverScene: scene:coverScene];
    
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Exporting your scene... WAIT OK!? otherwise your ipad might EXPLODE...BOOM!"];
    
    [self generateSceneVideo :scene:[theSceneUtility getMergedImagesArray]:[theSceneUtility getExportAudioURLs]:indexPath:@"scene only"];

}
- (void)exportMusical:(Show*)show
{
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Exporting your musical... WAIT OK!? otherwise your ipad might EXPLODE...BOOM!"];
    [scenesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:1];
        Scene *scene = (Scene*)obj;
        CoverScene *coverScene = [theCover coverSceneForSceneHash:scene.hash];
        theSceneUtility = [[SceneUtility alloc] initWithSceneAndCoverScene: scene:coverScene];
        [self generateSceneVideo:scene:[theSceneUtility getMergedImagesArray]:[theSceneUtility getExportAudioURLs]:indexPath:@"scenes for musical"];
    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    if(indexPath.section == 0){
        [self exportMusical:[musicalArray objectAtIndex:0]];
    }else if(indexPath.section == 1){
        Scene *selectedScene = [scenesArray objectAtIndex:indexPath.row];
        CoverScene *selectedCoverScene = [theCover coverSceneForSceneHash:selectedScene.hash];
        [self exportScene :selectedScene:selectedCoverScene:indexPath];
    }
       
}

@end

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
#import "FacebookUploader.h"
#import "YouTubeUploader.h"
#import "ImageToVideoConverter.h"
#import "MiniMusicalStarUtilities.h"
#import "ExportedAsset.h"

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
@synthesize facebookUploadImage;
@synthesize youtubeUploadImage;
@synthesize facebookUploader;
@synthesize youTubeUploader;
@synthesize context;

-(void)dealloc
{
    [tempMusicalContainer release];
    [musicalArray release];
    [scenesArray release];
    [exportedAssetsArray release];
    [timer release];
    [theSceneUtility release];
    [theShow release];
    [context release];
    [facebookUploadImage release];
    [youtubeUploadImage release];
    [facebookUploader release];
    [youTubeUploader release];
    
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
    progressBarFrame.origin.x = 600;
    progressBarFrame.origin.y = 45;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.view cellForRowAtIndexPath:indexPath];
    UIProgressView *prog = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    prog.frame= progressBarFrame;
    [cell.contentView addSubview:prog];
    [prog setProgress:0];

    NSString *exportFilename = [@"/musical_" stringByAppendingString:[[MiniMusicalStarUtilities getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *outputFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:exportFilename]];
    [self processExportSession :composition:nil:creditsFileURL:outputFileURL:prog:@"musical appending"];

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
    
    facebookUploadImage = [UIImage imageNamed:@"facebook_32.png"];
    youtubeUploadImage = [UIImage imageNamed:@"youtube_32.png"];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0){
        return @"Export Musicals";
    }else if (section==1){
        return @"Export Scenes";
    }else if (section ==2){
        return @"Exported Content";
    }
    return nil;
}

- (void) processExportSession: (AVMutableComposition*) composition:(NSURL*)videoFileURL:(NSURL*)creditsFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSString*) state
{
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:composition];
    if ([compatiblePresets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:composition presetName:AVAssetExportPresetPassthrough];
        
        exportSession.outputURL = outputFileURL;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        NSArray *userInfo = [NSArray arrayWithObjects:prog,exportSession,nil];
        NSTimer *progressBarLoader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshProgressBar:) userInfo:userInfo repeats:YES];
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export Completed");
                    [self exportCompleted: videoFileURL:creditsFileURL:outputFileURL:prog:progressBarLoader:state];
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

-(void) sessionExport: (AVMutableComposition*) composition: (NSURL*)videoFileURL: (NSURL*)creditsFileURL: (NSURL*)outputFileURL: (NSIndexPath*) indexPath: (NSString*) state
{
    
    //draw the progress bar
    CGRect progressBarFrame;
    progressBarFrame.size.width = 300;
    progressBarFrame.size.height = 300;
    progressBarFrame.origin.x = 600;
    progressBarFrame.origin.y = 45;
    
    UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.view cellForRowAtIndexPath:indexPath];
    UIProgressView *prog = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    prog.frame= progressBarFrame;
    [cell.contentView addSubview:prog];
    
    [self processExportSession :composition:videoFileURL:creditsFileURL:outputFileURL:prog:state];
    
}
- (void) exportCompleted: (NSURL*) videoFileURL: (NSURL*) creditsFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSTimer*) progressBarLoader: (NSString*) state
{
    if ([state isEqualToString: @"scene only"]){
        //save the URL into a new model
        ExportedAsset *newAsset = [NSEntityDescription insertNewObjectForEntityForName:@"ExportedAsset" inManagedObjectContext:self.context];
        newAsset.isFullShow = NO;
        newAsset.exportPath = [outputFileURL absoluteString];
        newAsset.title = @"Your Exported Scene";
        newAsset.originalHash = @"The hash of the original scene that you exported from";
        newAsset.exportHash = @"Use some kind of unique hash down here";
        
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
        newAsset.isFullShow = YES;
        newAsset.exportPath = [outputFileURL absoluteString];
        newAsset.title = @"Your Exported Musical";
        newAsset.originalHash = @"The hash of the original scene that you exported from";
        newAsset.exportHash = @"Use some kind of unique hash down here";
        
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
    [self.tableView reloadData];
    
    //temp only, trying CALayer
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,640,480)];
    
    [self.view addSubview:view];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:[@"Documents" stringByAppendingPathComponent:@"coverflow1.png"]]];
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
        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero,brandAsset.duration) 
                         ofAsset:brandAsset
                         atTime:composition.duration
                           error:&error];
    }
    

    //session export
    [self sessionExport :composition:videoFileURL:creditsFileURL:outputFileURL:indexPath:state];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0){
        return [musicalArray count];
    }else if (section == 1){
        return [scenesArray count];
    }else if(section == 2){
        return [exportedAssetsArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UIButton *facebookUploadButton;
    UIButton *youtubeUploadButton;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        facebookUploadButton = [[UIButton alloc] initWithFrame:CGRectMake(800, 25, 32, 32)];
        [cell.contentView addSubview:facebookUploadButton];
        facebookUploadButton.tag = 1;
        [facebookUploadButton release];
        
        youtubeUploadButton = [[UIButton alloc] initWithFrame:CGRectMake(850, 25, 32, 32)];
        [cell.contentView addSubview:youtubeUploadButton];
        youtubeUploadButton.tag = 2;
        [youtubeUploadButton release];
        
        [facebookUploadButton addTarget:self action:@selector(facebookUploadButtonIsPressed:) 
                      forControlEvents:UIControlEventTouchDown];
        [youtubeUploadButton addTarget:self action:@selector(youtubeUploadButtonIsPressed:) 
                      forControlEvents:UIControlEventTouchDown];
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
        
        facebookUploadButton = (UIButton*)[cell.contentView viewWithTag:1];
        youtubeUploadButton = (UIButton*)[cell.contentView  viewWithTag:2];
        [facebookUploadButton setImage:facebookUploadImage forState:UIControlStateNormal];
        [youtubeUploadButton setImage:youtubeUploadImage forState:UIControlStateNormal];
    }
    
    return cell;
    
    
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
    
    [self generateSceneVideo :scene:[theSceneUtility getMergedImagesArray]:[theSceneUtility getExportAudioURLs]:indexPath:@"scene only"];
}
- (void)exportMusical:(Show*)show
{
    

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
    }else if(indexPath.section == 2){
//        UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.view cellForRowAtIndexPath:indexPath];
        NSURL *fileURL = [exportedAssetsArray objectAtIndex:indexPath.row];
        [self playMovie:fileURL];
    }
    
   
}

- (void) playMovie:(NSURL*)filePath
{
    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:filePath];

    // Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)]) {
        // Use the new 3.2 style API
        
        [moviePlayer setFullscreen:YES animated:YES];
        [moviePlayer.view setFrame:self.view.bounds];
        moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        moviePlayer.shouldAutoplay = YES;
//        [self.view setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:moviePlayer.view];
        self.navigationController.navigationBarHidden = YES;
        [moviePlayer play];
    }   
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *moviePlayer = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer];
    
    // If the moviePlayer.view was added to the view, it needs to be removed
    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)]) {
        [moviePlayer.view removeFromSuperview];
    }
    self.navigationController.navigationBarHidden = NO;
    
    [moviePlayer release];
}

#pragma mark - IBAction events

- (void)facebookUploadButtonIsPressed:(UIButton*)sender
{
    ExportedAsset *selectedAsset = (ExportedAsset*)[exportedAssetsArray objectAtIndex:[self getTableViewRow:sender]];
    facebookUploader = [[FacebookUploader alloc] init];
    NSURL *url = [NSURL URLWithString:selectedAsset.exportPath];
    [facebookUploader uploadWithProperties:url title:@"Uploaded with Mini Musical Star" desription:@""];
}

- (void)youtubeUploadButtonIsPressed:(UIButton*)sender
{
    ExportedAsset *selectedAsset = (ExportedAsset*)[exportedAssetsArray objectAtIndex:[self getTableViewRow:sender]];
    youTubeUploader = [[YouTubeUploader alloc] init];
    NSURL *url = [NSURL URLWithString:selectedAsset.exportPath];
    [youTubeUploader uploadWithProperties:url title:@"Uploaded with Mini Musical Star" desription:@""];
}

- (int)getTableViewRow:(UIButton*)sender
{
    UITableViewCell *cell = (UITableViewCell*)sender.superview.superview;
    UITableView *table = (UITableView*)cell.superview;
    NSIndexPath *indexPath = [table indexPathForCell:cell];
    return [indexPath row];
}

@end

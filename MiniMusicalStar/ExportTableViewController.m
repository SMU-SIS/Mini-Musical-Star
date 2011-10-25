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

@implementation ExportTableViewController

@synthesize theShow;
@synthesize theCover;
@synthesize theSceneUtility;
@synthesize timer;
@synthesize musicalArray;
@synthesize scenesArray;
@synthesize exportedFilesArray;
@synthesize uploadBarButtonItem;
@synthesize mmsFacebook;
@synthesize tempMusicalContainer;

-(void)dealloc
{
    [tempMusicalContainer release];
    [musicalArray release];
    [scenesArray release];
    [exportedFilesArray release];
    [timer release];
    [theSceneUtility release];
    [theShow release];
    [mmsFacebook release];
    [super dealloc];
}


- (id)initWithStyle:(UITableViewStyle)style:(Show*)show:(Cover*)cover
{
    self = [super initWithStyle:style];
    if (self) {
        self.theShow = show;
        self.theCover = cover;
        self.musicalArray = [NSArray arrayWithObject:show];
        self.scenesArray = [show.scenes allValues];
        self.exportedFilesArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.tempMusicalContainer = [[NSMutableArray alloc] init];
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
    
    //add credits
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

    NSString *exportFilename = [@"/musical_" stringByAppendingString:[[AudioEditorViewController getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *outputFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:exportFilename]];
    [self processExportSession:composition:nil:outputFileURL:prog:@"musical appending"];

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
    
    //following codes is for testing uploading, they will be removed
    uploadBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(uploadToFacebook)];          
    self.navigationItem.rightBarButtonItem = uploadBarButtonItem;
}

- (void)uploadToFacebook
{
//    FacebookUploader *facebookUploader = [[[FacebookUploader alloc] init] autorelease];
//    [facebookUploader uploadToFacebook];
    
    YouTubeUploader *youtubeUploader = [[[YouTubeUploader alloc] init] autorelease];
    [youtubeUploader uploadVideoFile];
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

- (void) processExportSession: (AVMutableComposition*) composition:(NSURL*)videoFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSString*) state
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
                    [self exportCompleted:videoFileURL:outputFileURL:prog:progressBarLoader:state];
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

-(void) sessionExport: (AVMutableComposition*) composition: (NSURL*)videoFileURL: (NSURL*)outputFileURL: (NSIndexPath*) indexPath: (NSString*) state
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
    
    [self processExportSession :composition:videoFileURL:outputFileURL:prog:state];
    
}
- (void) exportCompleted: (NSURL*) videoFileURL: (NSURL*) outputFileURL: (UIProgressView*) prog: (NSTimer*) progressBarLoader: (NSString*) state
{
    if ([state isEqualToString: @"scene only"]){
        [self.exportedFilesArray addObject:[outputFileURL lastPathComponent]];
        [self removeFileAtPath:videoFileURL];
    }else if ([state isEqualToString: @"scenes for musical"]){
        [self.tempMusicalContainer addObject:outputFileURL];
        [self allScenesExportedNotificationSender];
        [self removeFileAtPath:videoFileURL];
    }else if ([state isEqualToString: @"musical appending"]){
        [self.exportedFilesArray addObject:@"musical"];
        [tempMusicalContainer enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self removeFileAtPath:obj];
        }];
        [tempMusicalContainer removeAllObjects];
    }
    [prog removeFromSuperview];
    [progressBarLoader invalidate];
    [self.tableView reloadData];
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
    NSString *videoFilename = [@"/vid_" stringByAppendingString:[[AudioEditorViewController getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    NSURL *videoFileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:videoFilename]];
    
    NSString *exportFilename = [@"/scene_" stringByAppendingString:[[AudioEditorViewController getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
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
//    CMTimeRangeShow(CMTimeRangeMake(kCMTimeZero,videoAsset.duration));
    

//    CMTimeRangeShow(CMTimeRangeMake(kCMTimeZero,brandAsset.duration));
//    CMTimeShow(composition.duration);
//    [composition insertEmptyTimeRange:CMTimeRangeMake(videoAsset.duration, CMTimeMake(5,1))];
    if([state isEqualToString: @"scene only"]){
        NSString *brandAssetPath =[[NSBundle mainBundle] pathForResource:@"lastclip" ofType:@"mov"];
        AVURLAsset *brandAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:brandAssetPath] options:nil];
        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero,brandAsset.duration) 
                         ofAsset:brandAsset
                         atTime:composition.duration
                           error:&error];
    }
//    CMTimeShow(videoAsset.duration);
//    CMTimeShow(composition.duration);
    
//    [composition.tracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        AVMutableCompositionTrack *track = obj;
//        NSLog(@"%@",track.description);
//    }];

//    NSLog(@"PRINT %@",ok);
//    NSLog(@"err %@", error);
//    NSLog(@"Brand tracks %@",brandAsset.tracks);
//    NSLog(@"tracks: %@",composition.tracks);
    

    //session export
    [self sessionExport :composition:videoFileURL:outputFileURL:indexPath:state];

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
        return [exportedFilesArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if(indexPath.section ==0){
        Show *show = [musicalArray objectAtIndex:0];
        cell.imageView.image = show.coverPicture;
        cell.textLabel.text = show.title;
        return cell;
    }else if(indexPath.section ==1){
        Scene *scene = [scenesArray objectAtIndex:indexPath.row];
        cell.imageView.image = scene.coverPicture;
        cell.textLabel.text = scene.title;
        return cell;
    }else{
        cell.textLabel.text = [exportedFilesArray objectAtIndex:indexPath.row];
        return cell;
    }

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
    
    [self generateSceneVideo:scene:[theSceneUtility getMergedImagesArray]:[theSceneUtility getExportAudioURLs]:indexPath:@"scene only"];
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
        [self exportScene:selectedScene:selectedCoverScene:indexPath];
    }else if(indexPath.section == 2){
        UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.view cellForRowAtIndexPath:indexPath];
        NSURL *fileURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:cell.textLabel.text]];
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
        
        [moviePlayer.view setFrame:self.view.bounds];
        moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        moviePlayer.shouldAutoplay = YES;
        [self.view setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:moviePlayer.view];
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
    
    [moviePlayer release];
}



@end

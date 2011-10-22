//
//  ExportTableViewController.m
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 17/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExportTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "YouTubeUploader.h"

@implementation ExportTableViewController

@synthesize theShow;
@synthesize theCover;
@synthesize theSceneUtility;
@synthesize exportRunning;
@synthesize exportSession;
@synthesize timer;
@synthesize musicalArray;
@synthesize scenesArray;
@synthesize exportedFilesArray;
@synthesize exportFilename;
@synthesize uploadBarButtonItem;
@synthesize mmsFacebook;

-(void)dealloc
{
    [exportFilename release];
    [musicalArray release];
    [scenesArray release];
    [exportedFilesArray release];
    [timer release];
    [exportSession release];
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
    }
    return self;
}

- (void) loadArrays
{

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

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image size:(CGSize) size{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
                                          size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, 
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace, 
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), 
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(void) sessionExport: (AVMutableComposition*) composition: (NSString*)videoFilename: (NSIndexPath*) indexPath
{
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:composition];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        self.exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        
        //draw the progress bar
        CGRect progressBarFrame;
        progressBarFrame.size.width = 300;
        progressBarFrame.size.height = 300;
        progressBarFrame.origin.x = 600;
        progressBarFrame.origin.y = 45;
        
        if(indexPath !=nil)
        {
            UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.view cellForRowAtIndexPath:indexPath];
//            UIProgressView *prog = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
//            prog.frame= progressBarFrame;
//            [cell.contentView addSubview:prog];
//            [prog setProgress:0];
            
            exportSession.outputURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:exportFilename]];
            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
            
            CMTime start = CMTimeMakeWithSeconds(0, 1);
            CMTime duration = CMTimeMakeWithSeconds(1000, 1);
            CMTimeRange range = CMTimeRangeMake(start, duration);
            exportSession.timeRange = range;
//            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshProgressBar:) userInfo:prog repeats:YES];
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                switch ([exportSession status]) {
                    case AVAssetExportSessionStatusCompleted:
                        NSLog(@"Export Completed");
                        //delete unused video file
                        [[NSFileManager defaultManager] removeItemAtPath: [[ShowDAO userDocumentDirectory] stringByAppendingString:videoFilename] error: NULL];
//                        [prog removeFromSuperview];
                        [exportedFilesArray addObject:@"hihi"];
                        [self.tableView reloadData];
                        break;
                    case AVAssetExportSessionStatusFailed:
                        NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        NSLog(@"Export cancelled");
                        break;
                    default:
                        break;
                }
//                [prog release];
                [exportSession release];

            }];
        }
//        else{
//            exportSession.outputURL = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:exportFilename]];
//            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
//            
//            CMTime start = CMTimeMakeWithSeconds(0, 1);
//            CMTime duration = CMTimeMakeWithSeconds(1000, 1);
//            CMTimeRange range = CMTimeRangeMake(start, duration);
//            exportSession.timeRange = range;
//            [exportSession exportAsynchronouslyWithCompletionHandler:^{
//                switch ([exportSession status]) {
//                    case AVAssetExportSessionStatusCompleted:
//                        NSLog(@"Export Completed");
//                        //delete unused video file
//                        [[NSFileManager defaultManager] removeItemAtPath: [[ShowDAO userDocumentDirectory] stringByAppendingString:videoFilename] error: NULL];
//                        break;
//                    case AVAssetExportSessionStatusFailed:
//                        NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
//                        break;
//                    case AVAssetExportSessionStatusCancelled:
//                        NSLog(@"Export cancelled");
//                        break;
//                    default:
//                        break;
//                }
//                [exportSession release];
//                
//            }];
//        
//        }

    }
}

- (void)refreshProgressBar:(NSTimer*) aTimer
{
    [aTimer.userInfo setProgress:self.exportSession.progress*50];

}

-(void) createImagesConvertedToVideo: (Scene*) theScene: (NSArray*) imagesArray: (NSString*) videoFilename :(CGSize) size
{
    
    __block NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:videoFilename]] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    AVAssetWriterInput* writerInput = [[AVAssetWriterInput
                                        assetWriterInputWithMediaType:AVMediaTypeVideo
                                        outputSettings:videoSettings] retain];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //add to buffer
    __block CVPixelBufferRef buffer = NULL;
    __block BOOL retry = NO;
    __block int i = 0;
    //sort the fucking array
    __block NSMutableArray *sortedTimingsArray = [NSMutableArray arrayWithArray:[theScene.pictureTimingDict allKeys]];
    [sortedTimingsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *strObj1 = (NSString *)obj1;
        NSString *strObj2 = (NSString *)obj2;
        
        if ([strObj1 intValue] > [strObj2 intValue])
        {
            return NSOrderedDescending;
        }
        
        else
        {
            return NSOrderedAscending;
        }
    }];
    
    [imagesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImage *img = (UIImage *)obj;
        if (adaptor.assetWriterInput.readyForMoreMediaData && !retry) 
        {
            int timeAt = [[sortedTimingsArray objectAtIndex:i] intValue];   
            CMTime presentTime=CMTimeMake(timeAt,1);
            buffer = [self pixelBufferFromCGImage:img.CGImage size:size];
            BOOL pixelBufferResult = [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
            
            if (pixelBufferResult == NO)
            {
                NSLog(@"failed to append buffer");
                NSLog(@"The error is %@", [videoWriter error]);
            }
            if(buffer)
                CVBufferRelease(buffer);
            [NSThread sleepForTimeInterval:0.05];
            i+=1;
        }
        else
        {
            NSLog(@"error");
            retry = YES;
        }
        
    }];
    
    //Finish the session:
    [writerInput markAsFinished];
    [videoWriter endSessionAtSourceTime:CMTimeMake(1000, 1)];
    [videoWriter finishWriting];
}

-(void)generateVideo: (Scene*) theScene: (NSArray*) imagesArray:(NSArray*) audioExportURLs:(NSIndexPath*) indexPath
{
    __block NSError *error = nil;
    CGSize size = CGSizeMake(640, 480);
    NSString *videoFilename = [@"/" stringByAppendingString:[[AudioEditorViewController getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];
    self.exportFilename = [@"/" stringByAppendingString:[[AudioEditorViewController getUniqueFilenameWithoutExt] stringByAppendingString:@".mov"]];

    //write image to video conversion
    [self createImagesConvertedToVideo:theScene :imagesArray :videoFilename :size];
    
    //now i will combine track and video
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:videoFilename]] options:nil];
    
    __block AVMutableCompositionTrack *compositionAudioTrack1 = NULL;
    
    [audioExportURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *audioURL = (NSURL*)obj;
        AVURLAsset* audioAsset1 = [[AVURLAsset alloc]initWithURL:audioURL options:nil];
        
        compositionAudioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero,audioAsset1.duration) 
                                        ofTrack:[[audioAsset1 tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] 
                                         atTime:kCMTimeZero
                                          error:&error];
        
    }];
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAsset.duration) 
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0] 
                                    atTime:kCMTimeZero error:&error];
    
    //session export
    [self sessionExport:composition:videoFilename:indexPath];

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
        cell.textLabel.text = exportFilename;
        cell.detailTextLabel.text = @"click to play";
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
    
    [self generateVideo:scene:[theSceneUtility getMergedImagesArray]:[theSceneUtility getExportAudioURLs]:indexPath];
}

- (void)exportMusical:(Show*)show
{
    [scenesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:1];
        Scene *scene = (Scene*)obj;
        CoverScene *coverScene = [theCover coverSceneForSceneHash:scene.hash];
        theSceneUtility = [[SceneUtility alloc] initWithSceneAndCoverScene: scene:coverScene];
        [self generateVideo:scene:[theSceneUtility getMergedImagesArray]:[theSceneUtility getExportAudioURLs]:indexPath];
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

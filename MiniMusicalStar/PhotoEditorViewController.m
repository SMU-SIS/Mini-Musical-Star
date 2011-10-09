//
//  PhotoEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoEditorViewController.h"

@implementation PhotoEditorViewController

@synthesize leftPicture, rightPicture, centerPicture, theScene, imagesArray, theCoverScene, context, currentSelectedCover, cameraPopupViewController, delegate;

-(void)dealloc
{
    [leftPicture release];
    [rightPicture release];
    [centerPicture release];
    [theScene release];
    [imagesArray release];
    [theCoverScene release];
    [context release];
    [cameraPopupViewController release];
    [super dealloc];
}


- (id)initWithScene:(Scene *)aScene andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self)
    {
        self.theScene = aScene;
        self.theCoverScene = aCoverScene;
        self.context = aContext;
        self.imagesArray = [[NSMutableArray alloc]init];
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
    ((AFOpenFlowView *)self.view).viewDelegate = self;
    [self performSelector:@selector(loadImagesIntoOpenFlow)];
    
}

- (void) loadImagesIntoOpenFlow
{
    loadImagesOperationQueue = [[NSOperationQueue alloc] init];
    
    int seconds = 0;
    int processedImages = 0;
    int numberOfImages = [theScene.pictureDict count];
    
    while (processedImages < numberOfImages)
    {
        Picture *thePicture = [theScene pictureForAbsoluteSecond:seconds];
        if (thePicture)
        {
            //check if there is a cover picture
            CoverScenePicture *coverPicture = [theCoverScene pictureForOriginalHash:thePicture.hash];
            
            if (coverPicture)
            {
                [(AFOpenFlowView *)self.view setImage: [coverPicture image] forIndex: processedImages];
                [self.imagesArray addObject:[coverPicture image]];
            }
            
            else
            {
                [(AFOpenFlowView *)self.view setImage: thePicture.image forIndex: processedImages];
                [self.imagesArray addObject:thePicture.image];
//                NSLog(@" AHHH %@",[self.imagesArray count]);

            }
            
            processedImages++;
        }
        
        seconds++;
    }
    
	[(AFOpenFlowView *)self.view setNumberOfImages:numberOfImages];
    if (numberOfImages > 0) [self setSliderImages: 0];
}

- (BOOL) setSliderImages:(UInt32)timeAt
{
    if (imagesArray.count > 0)
    {
        [(AFOpenFlowView *)self.view setSelectedCover:[theScene pictureNumberToShowForSeconds:timeAt]];
        [(AFOpenFlowView *)self.view centerOnSelectedCover:true];
    }

    
    return YES;
    
}

- (int)replaceCenterImage: (UIImage*)image
{
    [(AFOpenFlowView *)self.view setImage:image forIndex:self.currentSelectedCover];
    [self.imagesArray replaceObjectAtIndex:self.currentSelectedCover withObject:image];
    return self.currentSelectedCover;
}


- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index
{    
    [self.delegate setSliderPosition:[self.theScene startTimeOfPictureIndex:index]];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index
{
    //empty for now
}

- (void) playIt
{
    //play the fucking player
    NSURL *url = [NSURL fileURLWithPath:[[ShowDAO getUserDocumentDir] stringByAppendingString:@"/finally.mov"]];
    [delegate playMovie:url];
}

//for the AFCoverFlow delegate
- (UIImage *)defaultImage
{
    return nil;
}

- (IBAction) popupCameraOptions: (id) sender
{
    
    if(![self.delegate isRecording]){
        //get a reference to the current selected photo
        Picture *pic = [theScene pictureForIndex:self.currentSelectedCover];
        
        CameraPopupViewController *overlayView = [[CameraPopupViewController alloc] initWithCoverScene:theCoverScene andContext:context originalHash:pic.hash];
        
        [overlayView.view setAlpha:0.0];
        [self.view addSubview:overlayView.view];
        [UIView beginAnimations:nil context:nil];
        [overlayView.view setAlpha:1.0];
        [UIView commitAnimations];
        
        [delegate stopPlayer];
        
        [overlayView setDelegate:self];
    }

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

-(IBAction)generateVideo
{
    CGSize size = CGSizeMake(640, 480);
    __block NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:[[ShowDAO getUserDocumentDir] stringByAppendingString:@"/test.mov"]] fileType:AVFileTypeQuickTimeMovie
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
    
    [self.imagesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
    
    //now i will combine track and video
    AVMutableComposition* composition = [AVMutableComposition composition];
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:[[ShowDAO getUserDocumentDir] stringByAppendingString:@"/test.mov"]] options:nil];
    
    __block AVMutableCompositionTrack *compositionAudioTrack1 = NULL;
    [[delegate getExportAudioURLs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *audioURL = (NSURL*)obj;
        AVURLAsset* audioAsset1 = [[AVURLAsset alloc]initWithURL:audioURL options:nil];
//        NSLog(@"audioAsset : %@",[audioAsset1 URL]);
//        NSLog(@"is it this %@",[NSURL fileURLWithPath:[[ShowDAO getUserDocumentDir] stringByAppendingString:audio.path]]);
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

    
    //NOW I EXPORT, FINALLYZZZZ
    __block BOOL ready = NO;
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:composition];
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:composition presetName:AVAssetExportPresetLowQuality];
        
        
        exportSession.outputURL = [NSURL fileURLWithPath:[[ShowDAO getUserDocumentDir] stringByAppendingString:@"/finally.mov"]];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds(0, 1);
        CMTime duration = CMTimeMakeWithSeconds(1000, 1);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"Export Completed");
                    ready = YES;
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
            
            [exportSession release];
        }];
        
    }
    while(!ready){
        //do nothing
    }
    [self playIt];

}




- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end

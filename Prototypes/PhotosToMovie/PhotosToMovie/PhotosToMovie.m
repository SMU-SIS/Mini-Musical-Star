//
//  PhotosToMovie.m
//  PhotosToMovie
//
//  Created by Jun Kit on 27/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotosToMovie.h"

@implementation PhotosToMovie

@synthesize photos, movieLength, timeIntervalBetweenPhotos, frameSettings;

-(void) postFinishedMovieRenderNotificationWithPath:(NSString *)filePath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoToMovieRenderFinished" object:self userInfo:[NSDictionary dictionaryWithObject:filePath forKey:@"MoviePath"]];
}

-(void) postRenderProgressNotificationWithPercentage:(float)progressPercentage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoToMovieRenderProgress" object:[NSNumber numberWithFloat:progressPercentage]];
}

- (id)initWithPhotos:(NSArray *)inputPhotos lengthOfMovie:(int)inputMovieLength timeIntervalBetweenPhotos: (int)inputTimeIntervalInSeconds
{
    self = [super init];
    if (self) {
        self.photos = inputPhotos;
        self.movieLength = inputMovieLength;
        self.timeIntervalBetweenPhotos = inputTimeIntervalInSeconds;
        
        //1 second is 20frames - this setting is from where one?
        frameSettings.eachPhotoLastsForNumberOfFrames = timeIntervalBetweenPhotos * 20;
        frameSettings.totalFramesForPhotosToCompleteOneLoop = frameSettings.eachPhotoLastsForNumberOfFrames * [photos count];
        
        NSLog(@"eachPhotoLastsForNumberOfFrames is %i, totalFramesForPhotosToCompleteOneLoop is %i", frameSettings.eachPhotoLastsForNumberOfFrames, frameSettings.totalFramesForPhotosToCompleteOneLoop);
    }
    
    return self;
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey, 
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, &pxbuffer);
    // CVReturn status = CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL); 
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (UIImage *)getImageForFrame: (int)frameNum
{ 
    //take the current frameNum, divide by totalFramesForPhotosToCompleteOneLoop
    int position = frameNum % frameSettings.totalFramesForPhotosToCompleteOneLoop;
    int whichPhotoToDisplay = position / frameSettings.eachPhotoLastsForNumberOfFrames;
    return [photos objectAtIndex:whichPhotoToDisplay];
}


- (void)createMovieFromPhotos
{    
    //render for iPad resolution at 1024x768
    CGSize videoSize = CGSizeMake(1024, 768);
    
    //calculate total number of frames for given time
    int totalFrames = movieLength * 20;
    
    //get the temp path to store the movie after rendering
    compressionDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"photos.m4v"];
    
    NSError *error = nil;
    
    //delete old photos.m4v if there is
    unlink([compressionDirectory UTF8String]);
    
    //initialize compression engine
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:compressionDirectory]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    //check for errors
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error = %@", [error localizedDescription]);
    
    //configure the video settings in a dictionary
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:videoSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:videoSize.height], AVVideoHeightKey, nil];
    
    //create an instance of AVAssetWriterInput to feed into the writer
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    /*
     *Now we need to deal with this thing called the PixelBuffer.
     *It basically works like this: imageFile -> pixelBuffer -> AVAssetWriterInput -> AVAssetWriter -> movie
     *Let's configure the pixel buffer settings first in a dictionary
     */
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    //now we create the input pixel buffer adaptor
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput 
        sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    //some debugging code to see if the input can be added into the writer
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput])
        NSLog(@"I can add this input");
    else
        NSLog(@"i can't add this input");

    //then let's go ahead and add the input and start the writer
    [videoWriter addInput:writerInput];
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //let's create a new dispatch queue for the encoding and a block-mutable frame variable
    dispatch_queue_t    dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
    int __block         frame = 0;
    
    //write the actual block...
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while ([writerInput isReadyForMoreMediaData])
        {
            //stop writing if we reach the total number of frames
            if(++frame >= totalFrames)
            {
                [writerInput markAsFinished];
                [videoWriter finishWriting];
                [videoWriter release];
                NSLog(@"done! find your movie at %@", compressionDirectory);
                [self postFinishedMovieRenderNotificationWithPath: compressionDirectory];
                break;
            }
            
            //write the image data
            CVPixelBufferRef buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[self getImageForFrame:frame] CGImage] size:videoSize];
            if (buffer)
            {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, 20)])
                    NSLog(@"FAIL");
                else
                    //NSLog(@"Success:%d", frame);
                    [self postRenderProgressNotificationWithPercentage:(float)frame/totalFrames];
                CFRelease(buffer);
            }
        }
    }];
    
    NSLog(@"writerInput returned asynchronously");

}



@end

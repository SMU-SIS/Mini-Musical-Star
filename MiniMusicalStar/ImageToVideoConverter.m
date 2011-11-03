//
//  ImageToVideoConverter.m
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 24/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageToVideoConverter.h"
#import "Show.h"
#import "SceneUtility.h"
#import "KensBurner.h"

@implementation ImageToVideoConverter




+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image size:(CGSize) size{
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

+ (void) createImagesConvertedToVideo: (Scene*) theScene: (NSArray*) imagesArray: (NSURL*) videoFileURL :(CGSize) size
{
    
    __block NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  videoFileURL fileType:AVFileTypeQuickTimeMovie
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
    __block NSMutableArray *sortedTimingsArray = theScene.getOrderedPictureTimingArray;
    
    [imagesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImage *img = (UIImage *)obj;
        
//        UIImageView *view = [[UIImageView alloc] initWithImage:img];
//        view.frame = CGRectMake(320,0,640,480); // some frame that zooms in on the image;
//        KensBurner *kensBurner = [[KensBurner alloc] initWithImageView:view];
//        [kensBurner startAnimation];
//        
//        img = [self imageFromLayer:view.layer];
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
//    
//    CMTime presentTime=CMTimeMake(11,1);
//    UIImage *blackImage = [UIImage imageNamed: @"blankblack.png"];
//    buffer = [self pixelBufferFromCGImage:blackImage.CGImage size:size];
//    [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
//    
    //Finish the session:
    [writerInput markAsFinished];
    [videoWriter endSessionAtSourceTime:CMTimeMake(1000, 1)];
    [videoWriter finishWriting];
}
+ (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outputImage;
}

+(UIImage *)imageFromText:(NSString *)text
{

    float white[] = {1.0, 1.0, 1.0, 1.0};
    UIGraphicsBeginImageContext(CGSizeMake(640,480));
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColor(context, white);
	CGContextFillRect(context, CGRectMake(0, 0, 640, 480));
	
    const char *charText = [text UTF8String];
	CGContextSetTextDrawingMode(context, kCGTextStroke);
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
	CGContextSelectFont(context, "Arial", 50.0, kCGEncodingMacRoman);
	CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(context, transform);
//    CGFloat textSize = CGContextGetTextWidthAndHeight(context, text);
	CGContextShowTextAtPoint(context, 10.0, 240.0, charText, strlen(charText));
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    
//    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
//    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
//    
//    // Write a UIImage to JPEG with minimum compression (best quality)
//    // The value 'image' must be a UIImage object
//    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
//    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
//    
//    // Write image to PNG
//    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
//    
//    // Let's check to see if files were successfully written...
//    
//    // Create file manager
//    NSError *error;
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    
//    // Point to Document directory
//    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    
//    // Write out the contents of home directory to console
//    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
//
//    
    return image;
}

+ (void) createTextConvertedToVideo: (NSArray*)creditsList: (NSURL*) creditsFileURL :(CGSize) size
{
    
    __block NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  creditsFileURL fileType:AVFileTypeQuickTimeMovie
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
    [creditsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *text = (NSString *)obj;
        UIImage *img = [self imageFromText:text];
        if (adaptor.assetWriterInput.readyForMoreMediaData && !retry) 
        {
            CMTime presentTime=CMTimeMake(idx * 3,1);
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

@end

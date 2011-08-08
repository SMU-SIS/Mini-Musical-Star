//
//  PhotosToMovie.h
//  PhotosToMovie
//
//  Created by Jun Kit on 27/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

typedef struct {
    int eachPhotoLastsForNumberOfFrames;
    int totalFramesForPhotosToCompleteOneLoop;
} PhotoFrameSettings;

@interface PhotosToMovie : NSObject {
    NSArray* photos;
    int movieLength;
    int timeIntervalBetweenPhotos;
    PhotoFrameSettings frameSettings;
    NSString *compressionDirectory;
}

@property (nonatomic, retain) NSArray* photos;
@property (nonatomic) int movieLength;
@property (nonatomic) int timeIntervalBetweenPhotos;
@property (nonatomic) PhotoFrameSettings frameSettings;

- (id)initWithPhotos:(NSArray *)inputPhotos lengthOfMovie:(int)inputMovieLength timeIntervalBetweenPhotos: (int)inputTimeIntervalInSeconds;
- (UIImage *)getImageForFrame: (int)frameNum;
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size;
- (void)createMovieFromPhotos;
@end


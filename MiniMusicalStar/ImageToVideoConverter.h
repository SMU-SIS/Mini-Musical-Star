//
//  ImageToVideoConverter.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 24/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Scene;
@class SceneUtility;

@interface ImageToVideoConverter : NSObject

+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image size:(CGSize) size;
+ (void) createImagesConvertedToVideo: (NSMutableArray*) sortedTimingsArray: (NSArray*) imagesArray: (NSURL*) videoFileURL :(CGSize) size;
@end

//
//  SimpleAudioRenderTestViewController.h
//  SimpleAudioRenderTest
//
//  Created by Jun Kit on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "ASBDHelper.h"
#import "CAErrorHandling.h"

@interface SimpleAudioRenderTestViewController : UIViewController {
    AVAssetReaderOutput *assetReaderOutput;
    
    int bufferSize;
    NSMutableData *tempBuffer;
    int writePosition;
    int readPosition;
    
}

@property (nonatomic, retain) AVAssetReaderOutput *assetReaderOutput;
@property (nonatomic) double startingFrameCount;

- (void)loadAudioFile;
- (void)setupRemoteIOAudioUnit;
@end

//
//  PhotosToMovieViewController.h
//  PhotosToMovie
//
//  Created by Jun Kit on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

#import "PhotosToMovie.h"
#import "AddAudioToMovie.h"
#import "NGMoviePlayerViewController.h"

@interface PhotosToMovieViewController : UIViewController {
    PhotosToMovie* ptm;
    
    IBOutlet UIButton* startEncodingButton;
    IBOutlet UIActivityIndicatorView* spinner;
    IBOutlet UIProgressView* progressBar;
    IBOutlet UILabel* endResultLabel;
    
}

@property (nonatomic, retain) UIButton* startEncodingButton;
@property (nonatomic, retain) UIActivityIndicatorView* spinner;
@property (nonatomic, retain) UIProgressView* progressBar;
@property (nonatomic, retain) UILabel* endResultLabel;

- (void)didPhotosToMovieFinishedRendering: (NSNotification *)notification;
- (IBAction)startEncoding:(id)sender;
- (void)updateProgressBarForPercentage:(NSNotification *)notification;
- (IBAction)playMovie;
-(void)playMovieWithAsset:(AVAsset *)aAVAsset;
@end

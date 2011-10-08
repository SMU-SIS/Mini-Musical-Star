//
//  VideoPlayerViewController.h
//  MiniMusicalStar
//
//  Created by Adrian on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlayerViewController : UIViewController

- (VideoPlayerViewController*)initWithVideoURL:(NSURL*)url;

@end

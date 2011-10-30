//
//  VideoUploaderViewController.h
//  MiniMusicalStar
//
//  Created by Tommi on 29/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoUploaderViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *uploadingIndicator;

- (void)facebookUploadHasStarted;
- (void)facebookUploadHasCompleted;

@end

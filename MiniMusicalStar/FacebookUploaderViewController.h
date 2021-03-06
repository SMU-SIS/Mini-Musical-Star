//
//  FacebookUploaderViewController.h
//  MiniMusicalStar
//
//  Created by Tommi on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "MiniMusicalStarAppDelegate.h"

@protocol FacebookUploaderDelegate <NSObject>
@required
- (void)removeFacebookUploadOverlay;
@end

@interface FacebookUploaderViewController : UIViewController
    <FBSessionDelegate, FBRequestDelegate>
{
    id <FacebookUploaderDelegate> delegate;
    
    bool uploadHasCompleted;
    bool isUploading;
}

@property (nonatomic, retain) IBOutlet UIButton *okButton;
@property (nonatomic, retain) IBOutlet UIView *centerView;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *uploadProgressView;

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSURL *videoNSURL;
@property (nonatomic, retain) NSString *videoTitle;
@property (nonatomic, retain) NSString *videoDescription;

- (id)initWithProperties:(NSURL*)aVideoNSURL title:(NSString*)aTitle description:(NSString*)aDescription;
- (void)startUpload;

- (IBAction)okButtonIsPressed;
- (IBAction)closeButtonIsPressed;

@end

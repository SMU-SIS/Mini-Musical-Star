//
//  YouTubeUploaderViewController.h
//  MiniMusicalStar
//
//  Created by Tommi on 31/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataServiceGoogleYouTube.h"

@protocol YouTubeUploaderDelegate <NSObject>
@required
- (void)youTubeUploadSuccess;
- (void)youTubeUploadNotSuccessful;
@end

@interface YouTubeUploaderViewController : UIViewController
{
    id <YouTubeUploaderDelegate> delegate;
    
    GDataServiceTicket *mUploadTicket;
    
    bool uploadHasCompleted;
    bool uploadWasStarted;
    bool userHasCancelled;
}

//from xib
@property (nonatomic, retain) IBOutlet UIButton *okButton;
@property (nonatomic, retain) IBOutlet UIView *centerView;
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIProgressView *uploadProgressView;

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) NSURL *videoNSURL;
@property (nonatomic, retain) NSString *videoTitle;
@property (nonatomic, retain) NSString *videoDescription;

- (GDataServiceGoogleYouTube *)youTubeService;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;
- (NSArray*)getUserCredentials;

- (id)initWithProperties:(NSURL*)aVideoNSURL title:(NSString*)aTitle description:(NSString*)aDescription;
- (void)startUpload;

@end

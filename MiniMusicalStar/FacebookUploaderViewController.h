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

@protocol FacebookUploaderViewControllerDelegate <NSObject>
@required
- (void) uploadSuccessful: (BOOL)success;
@end

@interface FacebookUploaderViewController : UIViewController
    <FBSessionDelegate, FBRequestDelegate>

@property (nonatomic, retain) IBOutlet UIButton *okButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *uploadIndicator;

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSURL *videoNSURL;
@property (nonatomic, retain) NSString *videoTitle;
@property (nonatomic, retain) NSString *videoDescription;
//@property (nonatomic, retain) ExportTableViewController *exportTableViewController;

//- (id)initWithProperties:(NSURL*)aVideoNSURL title:(NSString*)aTitle description:(NSString*)aDescription exportTableViewController:(ExportTableViewController*)aExportTableViewController;
//- (void)startUpload;

@end

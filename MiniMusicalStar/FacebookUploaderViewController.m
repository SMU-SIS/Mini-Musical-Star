//
//  FacebookUploaderViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploaderViewController.h"

@implementation FacebookUploaderViewController

@synthesize delegate;
@synthesize okButton;
@synthesize statusLabel;
@synthesize facebook;
@synthesize videoNSURL;
@synthesize videoTitle;
@synthesize videoDescription;
@synthesize uploadIndicator;
@synthesize centerView;

#pragma mark - init and dealloc

- (id)initWithProperties:(NSURL*)aVideoNSURL title:(NSString*)aTitle description:(NSString*)aDescription 
{
    self = [super initWithNibName:@"FacebookUploaderViewController" bundle:nil];
    if (self) {
        facebook = [[Facebook alloc] initWithAppId:@"185884178157618" andDelegate:self];
        
        self.videoNSURL = aVideoNSURL;
        self.title = aTitle;
        self.videoDescription = aDescription;
        
        uploadHasCompleted = NO;
        isUploading = NO;
    }
    return self;
}

- (void)dealloc
{   
    //from init
    [facebook release];
    [videoNSURL release];
    [videoTitle release];
    
//    if (facebook != nil) {
//        [facebook release];
//    }
                          
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statusLabel.text = @"Ready to upload? Click the button below?";
    
    [self.okButton setTitle:@"UPLOAD" forState:UIControlStateNormal];
    [self.okButton setImage:[UIImage imageNamed:@"fb_upload.png"] forState:UIControlStateNormal];
    
    self.uploadIndicator.hidesWhenStopped = YES;

    CGAffineTransform scale = CGAffineTransformMakeScale (2.0,2.0);
    self.uploadIndicator.transform = scale;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [okButton release];
    [uploadIndicator release];
    [centerView release];
    [statusLabel release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - instance methods

- (void)startUpload
{
    NSArray* permissions = [[NSArray alloc] initWithObjects:
                            @"publish_stream", nil];
    [facebook authorize:permissions];
    [permissions release];
    
    
}

#pragma mark - FBSession delegate methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
    NSString *filePath = [videoNSURL path];
    NSData *videoData = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   videoData, @"video.mov",
                                   @"video/quicktime", @"contentType",
                                   videoTitle, @"title",
                                   videoDescription, @"description",
                                   nil];
    [facebook requestWithGraphPath:@"me/videos"
                         andParams:params
                     andHttpMethod:@"POST"
                       andDelegate:self];
    
    isUploading = YES;
    
    [self.uploadIndicator startAnimating];
    [self.okButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    self.statusLabel.text = @"Uploading musical...";
    [self.okButton setImage:[UIImage imageNamed:@"fb_cancel.png"] forState:UIControlStateNormal];
    
    NSLog(@"The facebook upload has started! Please wait for next NSLog to confirm upload.");
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"inside fbDidNotLogin:(BOOL)cancelled");
    
    self.statusLabel.text = @"You did not login to Facebook successfully! Try again! Anyway...are you online?";
    [self.okButton setTitle:@"TRY AGAIN" forState:UIControlStateNormal];
    [self.okButton setImage:[UIImage imageNamed:@"fb_tryagain.png"] forState:UIControlStateNormal];
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    NSLog(@"inside fbDidLogout");
    self.statusLabel.text = @"You are logged out of Facebook. Please try again!";
    [self.okButton setTitle:@"TRY AGAIN" forState:UIControlStateNormal];
    [self.okButton setImage:[UIImage imageNamed:@"fb_tryagain.png"] forState:UIControlStateNormal];
}


#pragma mark - FBRequestDelegate delegate methods

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
    
    [self.uploadIndicator stopAnimating];    
    statusLabel.text = @"Upload complete!";
    [self.okButton setTitle:@"CLOSE" forState:UIControlStateNormal];
    [self.okButton setImage:[UIImage imageNamed:@"fb_close.png"] forState:UIControlStateNormal];
    uploadHasCompleted = YES;

    NSLog(@"Result of API call: %@", result);
    NSLog(@"The facebook upload is completed");
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    self.statusLabel.text = @"Upload failed. Try again?";
    [self.okButton setTitle:@"TRY AGAIN" forState:UIControlStateNormal];
    [self.okButton setImage:[UIImage imageNamed:@"fb_tryagain.png"] forState:UIControlStateNormal];
    
    isUploading = NO;
    
    NSLog(@"Failed with error: %@", [error localizedDescription]);
    NSLog(@"Err details: %@", [error description]);
}

#pragma mark - IBAction methods

- (IBAction)okButtonIsPressed
{    
    if ([self.okButton.titleLabel.text isEqualToString:@"UPLOAD"] || 
        [self.okButton.titleLabel.text isEqualToString:@"TRY AGAIN"]) {
        
        [self startUpload];
        self.okButton.titleLabel.text = @"CANCEL";
        
    } else if ([self.okButton.titleLabel.text isEqualToString:@"CANCEL"]) {
        
        if (isUploading) {
            [facebook cancelPendingRequest];
            isUploading = NO;
        }
        
        self.statusLabel.text = @"You have cancelled the download!";
        [self.uploadIndicator stopAnimating];
        [self.okButton setTitle:@"TRY AGAIN" forState:UIControlStateNormal];
        [self.okButton setImage:[UIImage imageNamed:@"fb_tryagain.png"] forState:UIControlStateNormal];
        
    } else if ([self.okButton.titleLabel.text isEqualToString:@"CLOSE"]) {
        [delegate removeFacebookUploadOverlay];
    }
}

- (IBAction)closeButtonIsPressed
{
    if (isUploading) {
        [facebook cancelPendingRequest];
    }
    
    [delegate removeFacebookUploadOverlay];
}

@end

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
    }
    return self;
}

- (void)dealloc
{   
    NSLog(@"inside FacebookUploaderViewController.m dealloc");
    
    [facebook release];
    [videoNSURL release];
    [videoTitle release];
    [videoDescription release];
    [statusLabel release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    okButton.enabled = NO; 
    self.okButton.titleLabel.text = @"Cancel";
    self.uploadIndicator.hidesWhenStopped = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - instance methods

- (void)startUpload
{
    [self.uploadIndicator startAnimating];
    self.statusLabel.text = @"Uploading musical...";
    
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
    
    
    NSLog(@"The facebook upload has started! Please wait for next NSLog to confirm upload.");
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"did not login");
    //handle
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    NSLog(@"logged out login");
    //handle
}


#pragma mark - FBRequestDelegate delegate methods

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	
    NSLog(@"Result of API call: %@", result);
    NSLog(@"The facebook upload is completed");
    
    [self.uploadIndicator stopAnimating];
    [okButton setTitle:@"Ok." forState:UIControlStateNormal];
    uploadHasCompleted = YES;
    
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    self.statusLabel.text = @"Upload failed. Please retry.";
    
    NSLog(@"Failed with error: %@", [error localizedDescription]);
    NSLog(@"Err details: %@", [error description]);
    
    self.okButton.titleLabel.text = @"Ok.";
    uploadHasCompleted = NO;
}

#pragma mark - IBAction methods

- (IBAction)okButtonIsPressed
{    
    if (uploadHasCompleted) {
        [delegate facebookUploadSuccess];
    } else {
        //if the upload did not complete
        [delegate facebookUploadFailed];
    }
}

@end

//
//  FacebookUploaderViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploaderViewController.h"

@implementation FacebookUploaderViewController

@synthesize facebook;
@synthesize videoNSURL;
@synthesize videoTitle;
@synthesize videoDescription;

- (id)initWithProperties:(NSURL*)aVideoNSURL title:(NSString*)aTitle description:(NSString*)aDescription
{
    self = [super initWithNibName:@"FacebookUploaderViewController" bundle:nil];
    if (self) {
        facebook = [[Facebook alloc] initWithAppId:@"185884178157618" andDelegate:self];
        
        MiniMusicalStarAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        appDelegate.facebook = self.facebook;
        
        self.videoNSURL = aVideoNSURL;
        self.title = aTitle;
        self.videoDescription = aDescription;
    }
    return self;
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

- (void)dealloc
{
    [facebook release];
    [videoNSURL release];
    [videoTitle release];
    [videoDescription release];
    
    [super dealloc];
}

#pragma mark - FBSession delegate methods

- (void)startUpload
{
    NSArray* permissions = [[NSArray alloc] initWithObjects:
                            @"publish_stream", nil];
    [facebook authorize:permissions];
    [permissions release];

}

#pragma mark - FBSession delegate methods

- (void)fbDidLogin {
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
    
//    [videoUploaderController facebookUploadHasStarted];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
}


#pragma mark - FBRequestDelegate delegate methods

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	//NSLog(@"Result of API call: %@", result);
    NSLog(@"The facebook upload is completed");
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"The facebook upload failed");
    NSLog(@"Failed with error: %@", [error localizedDescription]);
    NSLog(@"Err details: %@", [error description]);
}

@end

//
//  MMSFacebook.m
//  MiniMusicalStar
//
//  Created by Tommi on 22/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookUploader.h"
#import "MiniMusicalStarAppDelegate.h"

@implementation FacebookUploader

@synthesize facebook;
@synthesize videoNSURL;
@synthesize videoTitle;
@synthesize videoDescription;

- (id)init
{
    self = [super init];
    if (self) {
        facebook = [[Facebook alloc] initWithAppId:@"185884178157618" andDelegate:self];
        
        MiniMusicalStarAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate setFacebook:facebook];
    }
    
    return self;
}

- (void)dealloc
{
    [videoNSURL release];
    [videoTitle release];
    [videoDescription release];
    
    [facebook release];
    [super dealloc];
}

//to be deleted in future
- (void)uploadToFacebook
{
    self.videoTitle = @"Uploaded from Mini Musical Star!";
    self.videoDescription = @"Uploaded from Mini Musical Star";
    
    NSArray* permissions = [[NSArray alloc] initWithObjects:
                            @"publish_stream", nil];
    [facebook authorize:permissions];
    [permissions release];
}

//to be used in future
- (void)uploadVideoWithProperties:(NSURL*)aVideoNSURL title:(NSString*)aTitle desription:(NSString*)aDescription
{
    self.videoNSURL = aVideoNSURL;
    self.videoTitle = aTitle;
    self.videoDescription = aDescription;
    
    NSArray* permissions = [[NSArray alloc] initWithObjects:
                            @"publish_stream", nil];
    [facebook authorize:permissions];
    [permissions release];
}

#pragma mark - FBSession delegate methods

- (void)fbDidLogin {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mov"];
    //NSString *filePath = [videoNSURL path];
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

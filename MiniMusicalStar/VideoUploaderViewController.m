//
//  VideoUploaderViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 29/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoUploaderViewController.h"

@implementation VideoUploaderViewController

@synthesize uploadingIndicator;
@synthesize statusLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.uploadingIndicator.hidesWhenStopped = YES;
    self.statusLabel.textAlignment = UITextAlignmentCenter;
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

#pragma instance methods
- (void)facebookUploadHasStarted
{
    NSLog(@"i'm in facebookUploadHasStarted");
    
    [self.statusLabel setText:@"Uploading..."];
    [uploadingIndicator startAnimating];
}

- (void)facebookUploadHasCompleted
{
    [self.statusLabel setText:@"Uploading complete"];
    [uploadingIndicator stopAnimating];
}

@end

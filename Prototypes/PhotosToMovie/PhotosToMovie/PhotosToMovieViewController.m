//
//  PhotosToMovieViewController.m
//  PhotosToMovie
//
//  Created by Jun Kit on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotosToMovieViewController.h"

@implementation PhotosToMovieViewController

@synthesize startEncodingButton, spinner, progressBar, endResultLabel;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)didPhotosToMovieFinishedRendering: (NSNotification *)notification
{
    NSDictionary *notificationDict = notification.userInfo;
    NSLog(@"Yay! Received my notification! And the movie path is %@", [notificationDict objectForKey:@"MoviePath"]);
    spinner.hidden = YES;
    [spinner stopAnimating];
    endResultLabel.text = [notificationDict objectForKey:@"MoviePath"];
    
    
    [ptm release];
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    spinner.hidden = YES;
    progressBar.hidden = YES;
    endResultLabel.hidden = YES;

}

- (IBAction)addAudioToMovie:(id)sender
{
    AddAudioToMovie *audioAdder = [[AddAudioToMovie alloc] init];
    AVAsset *theComposition = [audioAdder addAudioToMovie:endResultLabel.text];
    [audioAdder release];
    
    [self playMovieWithAsset:theComposition];
    
}

- (IBAction)startEncoding:(id)sender
{
    startEncodingButton.enabled = NO;
    
    UIImage *img1 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pict1" ofType:@"JPG"]];
    UIImage *img2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pict2" ofType:@"JPG"]];
    UIImage *img3 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pict3" ofType:@"JPG"]];
    UIImage *img4 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pict4" ofType:@"JPG"]];
    
    NSArray *photos = [NSArray arrayWithObjects:img1, img2, img3, img4, nil];
    ptm = [[PhotosToMovie alloc] initWithPhotos:photos lengthOfMovie:15 timeIntervalBetweenPhotos:2];
    [ptm createMovieFromPhotos];
    
    
    NSLog(@"returned async back to view controller");
    
    //register for my notification of PhotoToMovieRenderFinished
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPhotosToMovieFinishedRendering:) name:@"PhotoToMovieRenderFinished" object:nil];
    
    //register for my notification of PhotoToMovieRenderProgress
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressBarForPercentage:) name:@"PhotoToMovieRenderProgress" object:nil];
    
    spinner.hidden = NO;
    progressBar.hidden = NO;
    endResultLabel.hidden = NO;
    [spinner startAnimating];
    
}

- (void)updateProgressBarForPercentage:(NSNotification *)notification
{
    NSNumber *progressPercentage = notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressBar setProgress:[progressPercentage floatValue]];
    });
    
}

- (IBAction)playMovie
{
    NSURL *audioURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Friday" ofType:@"mp3"]];
    AVAsset *audioAsset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
    NGMoviePlayerViewController *aMoviePlayerViewController = [[[NGMoviePlayerViewController alloc] initWithAVAsset:audioAsset delegate:self] autorelease];
	aMoviePlayerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:aMoviePlayerViewController animated:YES];
}

-(void)playMovieWithAsset:(AVAsset *)aAVAsset
{
    NGMoviePlayerViewController *aMoviePlayerViewController = [[[NGMoviePlayerViewController alloc] initWithAVAsset:aAVAsset delegate:self] autorelease];
	aMoviePlayerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:aMoviePlayerViewController animated:YES];
}

- (void)ngMoviePlayerDidFinish:(NGMoviePlayerViewController *)ngMoviePlayerViewController {
	NSError *error = ngMoviePlayerViewController.movieError;
	if (error != nil)
		NSLog(@"There was an error playing the movie: %@", error);
	[self dismissModalViewControllerAnimated:YES];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end

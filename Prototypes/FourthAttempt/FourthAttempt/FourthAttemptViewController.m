//
//  FourthAttemptViewController.m
//  FourthAttempt
//
//  Created by Jun Kit Lee on 11/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "FourthAttemptViewController.h"

@implementation FourthAttemptViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *bass = [[NSBundle mainBundle] pathForResource:@"bass" ofType:@"mp3"];
    NSString *drums = [[NSBundle mainBundle] pathForResource:@"drums" ofType:@"mp3"];
    NSString *guitar = [[NSBundle mainBundle] pathForResource:@"guitar" ofType:@"mp3"];
    NSString *keys = [[NSBundle mainBundle] pathForResource:@"keys" ofType:@"mp3"];
    NSString *vocals = [[NSBundle mainBundle] pathForResource:@"vocals" ofType:@"mp3"];
    
    NSArray *audioFiles = [NSArray arrayWithObjects:[NSURL fileURLWithPath:bass], [NSURL fileURLWithPath:drums], [NSURL fileURLWithPath:guitar], [NSURL fileURLWithPath:keys], [NSURL fileURLWithPath:vocals], nil];
    
    MixPlayerRecorder *player = [[MixPlayerRecorder alloc] initWithAudioFileURLs:audioFiles];
    [player play];
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

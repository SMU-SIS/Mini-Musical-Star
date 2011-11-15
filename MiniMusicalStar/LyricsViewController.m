//
//  LyricsViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LyricsViewController.h"

@implementation LyricsViewController

@synthesize lyricsScrollView;
@synthesize lyricsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [lyricsScrollView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed: @"note_for_lyrics.png"]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [lyricsScrollView release];
    [lyricsLabel release];
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

#define LYRICS_VIEW_WIDTH 460
#define LYRICS_VIEW_HEIGHT 530
#define LYRICS_VIEW_X 520
#define LYRICS_VIEW_Y 30

- (void)loadLyrics:(NSString*)someLyrics
{
    CGRect lyricsLabelFrame = lyricsLabel.bounds;
    
    lyricsLabelFrame.size = [someLyrics sizeWithFont:lyricsLabel.font constrainedToSize:CGSizeMake(LYRICS_VIEW_WIDTH-20, 100000) lineBreakMode:lyricsLabel.lineBreakMode];
    
    //set new size of label
    lyricsLabel.frame = CGRectMake(-15, 70, lyricsLabel.frame.size.width-100, lyricsLabelFrame.size.height);
    
    //set new content size of scroll view
    [lyricsScrollView setContentSize:CGSizeMake(lyricsLabel.frame.size.width, lyricsLabelFrame.size.height+100)];
    
    lyricsLabel.text = someLyrics;
}

@end

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
    [lyricsScrollView release];
    [lyricsLabel release];
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
    
    lyricsScrollView = nil;
    lyricsLabel = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - instance methods


#pragma mark - TracksTableViewDelegate methods

- (void)loadLyrics:(NSString*)aLyrics
{   
    CGSize maximumLabelSize = CGSizeMake(lyricsLabel.frame.size.width, 10000);
    
    CGSize expectedLabelSize = [aLyrics sizeWithFont:lyricsLabel.font constrainedToSize:maximumLabelSize lineBreakMode:lyricsLabel.lineBreakMode];
    
    CGRect newSize = lyricsLabel.frame;
    newSize.size.height = expectedLabelSize.height;
    lyricsLabel.frame = newSize;
    
    lyricsLabel.text = aLyrics;
        
    CGSize scrollViewSize = lyricsScrollView.frame.size;
    scrollViewSize.height = expectedLabelSize.height+100;
    [lyricsScrollView setContentSize:scrollViewSize]; 
}

@end

//
//  LyricsViewController.h
//  MiniMusicalStar
//
//  Created by Tommi on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TracksTableViewController.h"

@interface LyricsViewController : UIViewController
    <TracksTableViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *lyricsScrollView;
@property (nonatomic, retain) IBOutlet UILabel *lyricsLabel;

@end
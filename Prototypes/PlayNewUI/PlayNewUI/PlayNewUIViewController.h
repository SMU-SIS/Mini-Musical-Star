//
//  PlayNewUIViewController.h
//  PlayNewUI
//
//  Created by Tommi on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

@interface PlayNewUIViewController : UIViewController 
    <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>
{
    UITableView *trackTableView;
    UIView *trackCellRightPanel;
    UIPopoverController *lyricsPopoverController;
}

@property (nonatomic, retain) UITableView *trackTableView;
@property (nonatomic, retain) UIView *trackCellRightPanel;
@property (nonatomic, retain) UIPopoverController *lyricsPopoverController;

- (IBAction)scrollToX; //to be deleted
- (IBAction)lyricsAppear; //to be deleted

@end

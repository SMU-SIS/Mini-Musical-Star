//
//  PlayWithViewsViewController.h
//  PlayWithViews
//
//  Created by Tommi on 20/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NextView.h"

@interface PlayWithViewsViewController : UIViewController
{
    NextView *nextView;
}

@property (nonatomic, retain) NextView *nextView;

- (IBAction)ouch:(id)pid;

@end

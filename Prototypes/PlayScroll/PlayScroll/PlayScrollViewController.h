//
//  PlayScrollViewController.h
//  PlayScroll
//
//  Created by Tommi on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PlayScrollViewController : UIViewController
{
    IBOutlet UIScrollView *scrollView1;
}

@property (nonatomic, retain) UIScrollView *scrollView1;

- (void)layoutScrollImages;

@end
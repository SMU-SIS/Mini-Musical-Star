//
//  HiddenView.h
//  PlayScroll
//
//  Created by Tommi on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface HiddenView : UIView
{
@private
    // weak
    UIScrollView *underneathButton;
}

@property (nonatomic, assign) UIScrollView *underneathButton;

@end

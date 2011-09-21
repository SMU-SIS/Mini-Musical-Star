//
//  HiddenView.m
//  PlayScroll
//
//  Created by Tommi on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HiddenView.h"

@implementation HiddenView

@synthesize menuScrollView;

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event]) {
        return menuScrollView;
    }
   
    return nil;
}

@end

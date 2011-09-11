//
//  TrackPane.m
//  PlayNewUI
//
//  Created by Tommi on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackPane.h"

@implementation TrackPane

@synthesize tableViewCell;

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event]) {
        return tableViewCell;
    }
    return nil;
}

@end

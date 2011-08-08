//
//  NGMoviePlayerLowerControlsBackgroundView.m
//  bobcat
//
//  Created by Brent Simmons on 8/15/10.
//  Copyright 2010 NewsGator Technologies, Inc. All rights reserved.
//

#import "NGMoviePlayerLowerControlsView.h"


@implementation NGMoviePlayerLowerControlsView

- (void)drawRect:(CGRect)rect {
	UIImage *image = [UIImage imageNamed:@"movie_lower-controls_background"];
	[image drawAtPoint:self.bounds.origin blendMode:kCGBlendModeNormal alpha:1.0];
}


@end


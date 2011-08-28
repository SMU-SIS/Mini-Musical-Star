//
//  AudioMenu.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioMenu.h"


@implementation AudioMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect1 = CGRectMake(0, 0, 480, 600);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect1];
        imageView.image = [UIImage imageNamed:@"glee2.jpg"];
        
        [self addSubview:imageView];
        [imageView release];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end

//
//  TrackPane.h
//  PlayNewUI
//
//  Created by Tommi on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

@interface TrackPane : UIView
{
    CustomCell *tableViewCell;
}

@property (nonatomic, retain) CustomCell *tableViewCell;

@end

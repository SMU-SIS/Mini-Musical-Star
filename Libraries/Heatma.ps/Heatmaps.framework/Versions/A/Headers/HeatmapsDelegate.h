//
//  HeatmapsDelegate.h
//  Heatmaps
//
//  Copyright (c) 2011 SharQ sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Heatmaps.h"

@protocol HeatmapsDelegate <NSObject>

@required
@property(nonatomic,retain) Heatmaps *heatmaps;

@end

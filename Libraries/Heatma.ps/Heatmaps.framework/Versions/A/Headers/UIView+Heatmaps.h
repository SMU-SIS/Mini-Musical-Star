//
//  UIView+Heatmaps.h
//  Heatmaps
//
//  Copyright (c) 2011 SharQ sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMUIETracker.h"

@interface UIView (Heatmaps)

-(void)trackWithKey:(NSString*)key;
-(void)stopTracking;

//key
-(void)setKey:(NSString*)key;
-(NSString*)getKey;
-(NSString*)oID;

//Tracker
-(void)setTracker:(HMUIETracker*)tracker;
-(HMUIETracker*)getTracker;

@end

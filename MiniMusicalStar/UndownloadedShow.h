//
//  UndownloadedShow.h
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 14/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKProduct;
@interface UndownloadedShow : NSObject

@property (retain, nonatomic) NSString *showHash;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSURL *downloadURL;
@property (retain, nonatomic) UIImage *coverImage;
@property (retain, nonatomic) NSString *showDescription;
@property (retain, nonatomic) NSDecimalNumber *price;
@property (retain, nonatomic) SKProduct *skProduct;
@end

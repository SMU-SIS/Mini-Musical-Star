//
//  UndownloadedShow.h
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 14/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UndownloadedShow : NSObject

@property (nonatomic) int showID;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSURL *downloadURL;
@property (retain, nonatomic) UIImage *coverImage;

@end

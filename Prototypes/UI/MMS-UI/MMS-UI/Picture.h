//
//  Picture.h
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PictureCue.h"

@interface Picture : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSURL *path;
@property (retain, nonatomic) NSNumber *startTime;
@property (retain, nonatomic) NSNumber *duration;
@property (retain, nonatomic) NSMutableArray *pictureCueList;

- (Picture *)initPictureWithPropertyDictionary: (NSDictionary *) pDictionary;

@end

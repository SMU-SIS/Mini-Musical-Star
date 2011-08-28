//
//  Picture.h
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Picture : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSURL *path;
@property (retain, nonatomic) NSNumber *startTime;
@property (retain, nonatomic) NSNumber *duration;
@property (retain, nonatomic) NSArray *cueList;

- (Picture *)initWithPropertyDictionary: (NSDictionary *) pDictionary;

@end

//
//  Audio.h
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Audio : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSURL *path;
@property (nonatomic) BOOL *replaceable;
@property (retain, nonatomic) NSNumber *duration;
@property (retain, nonatomic) NSArray *cueList;

@end

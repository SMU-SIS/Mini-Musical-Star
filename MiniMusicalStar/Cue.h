//
//  Cue.h
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cue : NSObject

@property (retain, nonatomic) NSString *cueHash;
@property (nonatomic) int startTime;
@property (nonatomic) int endTime;
@property (retain, nonatomic) NSString *content;
@property (retain, nonatomic) NSURL *contentPath;

- (id)initWithCueHash: (NSString *)aCueHash startTime: (NSNumber *)aStartTime endTime: (NSNumber *)anEndTime content: (NSString *)aContent contentPath: (NSURL *)aContentPath;
@end

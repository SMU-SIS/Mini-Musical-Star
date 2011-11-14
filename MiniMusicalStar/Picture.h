//
//  Picture.h
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Cue;
@interface Picture : NSObject

@property (retain, nonatomic) NSString *hash;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) UIImage *image;
@property (assign, nonatomic) UInt32 startTime;
@property (assign, nonatomic) UInt32 duration;
@property (retain, nonatomic) NSMutableArray *pictureCueList;
@property (assign, nonatomic) UInt32 orderNumber;
@property (retain, nonatomic) Cue *theCue;

- (id)initWithHash:(NSString *)key dictionary:(NSDictionary *)obj assetPath:assetPath;

@end

//
//  Audio.h
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioCue.h"
@interface Audio : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *path;
@property (retain, nonatomic) NSNumber *replaceable;
@property (retain, nonatomic) NSNumber *duration;
@property (retain, nonatomic) NSString *lyrics;
@property (retain, nonatomic) NSMutableArray *audioCueList;

- (Audio *)initAudioWithPropertyDictionary: (NSDictionary *) pDictionary withPath: (NSString *)showPath;

@end

//
//  Cue.h
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioCue : NSObject

@property (retain, nonatomic) NSString *content;
@property (retain, nonatomic) NSNumber *time;
@property (retain, nonatomic) NSString *type;
@property (retain, nonatomic) NSNumber *duration;

- (AudioCue *)initWithPropertyDictionary: (NSDictionary *) pDictionary;

@end

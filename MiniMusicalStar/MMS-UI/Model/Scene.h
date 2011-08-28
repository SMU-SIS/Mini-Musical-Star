//
//  Scene.h
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Audio.h"
#import "Picture.h"

@interface Scene : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSNumber *duration;
@property (retain, nonatomic) NSMutableArray *audioList;
@property (retain, nonatomic) NSMutableArray *pictureList;

-(Scene *) initSceneWithPropertyDictionary:(NSDictionary *)propertyDictonary;

@end

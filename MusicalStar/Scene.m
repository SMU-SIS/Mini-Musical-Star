//
//  Scene.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Scene.h"

@implementation Scene
@synthesize title, duration, audioList, pictureList;

-(Scene *) initWithPropertyDictionary:(NSDictionary *)propertyDictionary
{
    self = [super init];
    if (self) {
        // Initialization code here.
        title = [propertyDictionary objectForKey:@"title"];
        duration = [propertyDictionary objectForKey:@"duration"];
        
        NSArray *audioArray = [propertyDictionary objectForKey:@"audio"];
        audioList = [[NSMutableArray alloc] initWithCapacity:audioArray.count];
        
        [audioArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *audioObjectDict = (NSDictionary *)obj;
            
            Audio *audioTrack = [[Audio alloc] initWithPropertyDictionary:audioObjectDict];
            [audioList addObject:audioTrack];
            [audioTrack release];
            
        }];
        
        NSArray *pictureArray = [propertyDictionary objectForKey:@"pictures"];
        pictureList = [[NSMutableArray alloc] initWithCapacity:pictureArray.count];
        
        [pictureArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *pictureObjectDict = (NSDictionary *)obj;
            
            Picture *scenePicture = [[Picture alloc] initWithPropertyDictionary:pictureObjectDict];
            [pictureList addObject:scenePicture];
            [scenePicture release];
        }];
    }
    
    return self;
}

@end

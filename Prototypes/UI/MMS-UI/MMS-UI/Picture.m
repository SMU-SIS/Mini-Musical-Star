//
//  Picture.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Picture.h"

@implementation Picture
@synthesize title, image, startTime, duration, pictureCueList;

- (Picture *)initPictureWithPropertyDictionary: (NSDictionary *) pDictionary: (NSString *) scenePath
{
    self = [super init];
    if (self) {
        title = [pDictionary objectForKey:@"title"];
        image = [[UIImage alloc] initWithContentsOfFile:[scenePath stringByAppendingString:[pDictionary objectForKey:@"path"]]];
        startTime = [pDictionary objectForKey:@"startTime"];
        duration = [pDictionary objectForKey:@"duration"];
        NSArray *cueArray = [pDictionary objectForKey:@"cues"];
        pictureCueList = [[NSMutableArray alloc] initWithCapacity:cueArray.count];
        
        [cueArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *cueObjectDict = (NSDictionary *)obj;
            
            PictureCue *pictureCue = [[PictureCue alloc] initPictureCueWithPropertyDictionary:cueObjectDict];
            [pictureCueList addObject:pictureCue];
            [pictureCue release];
            
        }];
        
    }
    
    return self;
}

- (void)dealloc
{
    [title release];
    [image release];
    [startTime release];
    [duration release];
    [pictureCueList release];
    [super dealloc];
}


@end

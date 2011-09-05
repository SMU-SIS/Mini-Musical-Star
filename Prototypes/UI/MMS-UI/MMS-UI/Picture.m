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
        self.title = [pDictionary objectForKey:@"title"];
        self.image = [[UIImage alloc] initWithContentsOfFile:[scenePath stringByAppendingString:[pDictionary objectForKey:@"path"]]];
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        
        self.startTime = [NSNumber numberWithInt:[pDictionary objectForKey:@"startTime"]];
        self.duration = [NSNumber numberWithInt:[pDictionary objectForKey:@"duration"]];
        
        [f release];
        
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

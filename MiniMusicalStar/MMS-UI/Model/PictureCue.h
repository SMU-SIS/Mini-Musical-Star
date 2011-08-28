//
//  PictureCue.h
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureCue : NSObject

@property (retain, nonatomic) NSString *path;
@property (retain, nonatomic) NSString *type;

- (PictureCue *)initPictureCueWithPropertyDictionary: (NSDictionary *) pDictionary;

@end

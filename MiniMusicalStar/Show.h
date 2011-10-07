//
//  Show.h
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"

@interface Show : NSObject {
    
}

@property (retain, nonatomic) NSDictionary *data;

@property (retain, nonatomic) NSMutableDictionary *scenes;
@property (retain, nonatomic) NSMutableArray *scenesOrder;
@property (nonatomic) int showID;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *author;
@property (retain, nonatomic) NSDate *createdDate;
@property (retain) UIImage *coverPicture;
@property (retain, nonatomic) NSString *iTunesAlbumLink;
@property (retain, nonatomic) NSString *iBooksBookLink;

@property (retain, nonatomic) NSString *showAssetsLocation;

- (Show *)initShowWithPropertyListFile: (NSString *)pListFilePath atPath:(NSURL *)showPath;
- (Scene *)sceneForIndex:(int)idx;

@end

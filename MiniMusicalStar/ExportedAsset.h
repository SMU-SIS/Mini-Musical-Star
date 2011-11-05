//
//  ExportedAsset.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 31/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cover;

@interface ExportedAsset : NSManagedObject

@property (nonatomic, retain) NSString * exportHash;
@property (nonatomic, retain) NSString * exportPath;
@property (nonatomic, retain) NSNumber * isFullShow;
@property (nonatomic, retain) NSString * originalHash;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) Cover *cover;

- (BOOL) deleteExportFile;

@end

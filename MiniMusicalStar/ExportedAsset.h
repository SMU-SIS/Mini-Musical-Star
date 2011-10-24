//
//  ExportedAsset.h
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 24/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 Instructions for use:
 
 ExportedAsset *foo = [NSEntityDescription insertNewObjectForEntityForName: @"ExportedAsset" inManagedObjectContext: context];
 foo.title = @"Blah blah blah";
 ...
 NSError *error;
 [context save: error];
 
 if (error)
 {
    //handle the saving error
 }
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ExportedAsset : NSManagedObject

@property (nonatomic, retain) NSString * exportHash;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * exportPath;
@property (nonatomic) BOOL isFullShow;
@property (nonatomic, retain) NSString * originalHash;

@end

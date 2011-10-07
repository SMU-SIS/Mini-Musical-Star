//
//  CoverScenePicture.h
//  MMS-UI
//
//  Created by Jun Kit Lee on 17/9/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CoverScene;

@interface CoverScenePicture : NSManagedObject {
@private
}
@property (retain, nonatomic) NSString *OriginalHash;
@property (nonatomic, retain) NSNumber * OrderNumber;
@property (nonatomic, retain) NSString * Path;
@property (nonatomic, retain) CoverScene *CoverScene;

-(UIImage *)image;

@end

//
//  Cover.h
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 27/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CoverScene;

@interface Cover : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * coverOfShowHash;
@property (nonatomic, retain) NSDate * created_date;
@property (nonatomic, retain) NSString * originalHash;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *Scenes;
@end

@interface Cover (CoreDataGeneratedAccessors)

- (void)addScenesObject:(CoverScene *)value;
- (void)removeScenesObject:(CoverScene *)value;
- (void)addScenes:(NSSet *)values;
- (void)removeScenes:(NSSet *)values;
- (CoverScene *)coverSceneForSceneHash:(NSString *)sceneHash;

- (void)purgeRelatedFiles;

@end

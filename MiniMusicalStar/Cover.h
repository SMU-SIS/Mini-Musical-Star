//
//  Cover.h
//  MMS-UI
//
//  Created by Jun Kit Lee on 17/9/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoverScene.h"

@interface Cover : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * cover_of_showHash;
@property (retain, nonatomic) NSString *originalHash;
@property (nonatomic, retain) NSDate * created_date;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *Scenes;
@end

@interface Cover (CoreDataGeneratedAccessors)

- (void)addScenesObject:(NSManagedObject *)value;
- (void)removeScenesObject:(NSManagedObject *)value;
- (void)addScenes:(NSSet *)values;
- (void)removeScenes:(NSSet *)values;

- (BOOL)showWasEdited;
- (void)purgeRelatedFiles;
- (CoverScene *)coverSceneForSceneHash:(NSString *)sceneHash;
@end

//
//  CoverScene.h
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 9/10/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cover, CoverSceneAudio, CoverScenePicture;

@interface CoverScene : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString *sceneHash;
@property (nonatomic, retain) NSSet *Audio;
@property (nonatomic, retain) Cover *Cover;
@property (nonatomic, retain) NSSet *Picture;
@end

@interface CoverScene (CoreDataGeneratedAccessors)

- (void)addAudioObject:(CoverSceneAudio *)value;
- (void)removeAudioObject:(CoverSceneAudio *)value;
- (void)addAudio:(NSSet *)values;
- (void)removeAudio:(NSSet *)values;

- (void)addPictureObject:(CoverScenePicture *)value;
- (void)removePictureObject:(CoverScenePicture *)value;
- (void)addPicture:(NSSet *)values;
- (void)removePicture:(NSSet *)values;

- (CoverScenePicture *)pictureForOriginalHash:(NSString *)hash;
- (CoverScenePicture *)pictureForOrderNumber:(int)orderNum;
- (CoverSceneAudio *)audioForTrackTitle:(NSString *)trackTitle;


@end

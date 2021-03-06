//
//  CoverSceneAudio.h
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 9/10/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CoverScene;

@interface CoverSceneAudio : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * originalHash;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) CoverScene *CoverScene;
@property (retain, nonatomic) NSDate *createdDate;

- (BOOL)deleteAudioFile;

@end

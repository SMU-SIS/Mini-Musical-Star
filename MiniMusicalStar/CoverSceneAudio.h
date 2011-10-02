//
//  CoverSceneAudio.h
//  MMS-UI
//
//  Created by Jun Kit Lee on 17/9/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoverSceneAudio : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSManagedObject *CoverScene;

- (void)deleteAudioFile;

@end

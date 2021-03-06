//
//  CoverSceneAudio.m
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 9/10/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "CoverSceneAudio.h"
#import "CoverScene.h"


@implementation CoverSceneAudio
@dynamic originalHash;
@dynamic path;
@dynamic title;
@dynamic CoverScene;
@dynamic createdDate;

- (BOOL)deleteAudioFile
{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:self.path error:nil];
}

@end

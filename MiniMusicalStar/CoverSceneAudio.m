//
//  CoverSceneAudio.m
//  MMS-UI
//
//  Created by Jun Kit Lee on 17/9/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "CoverSceneAudio.h"


@implementation CoverSceneAudio
@dynamic path;
@dynamic title;
@dynamic CoverScene;

- (void)deleteAudioFile
{
    unlink([self.path UTF8String]);
}

@end

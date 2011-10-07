//
//  CoverScenePicture.m
//  MMS-UI
//
//  Created by Jun Kit Lee on 17/9/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "CoverScenePicture.h"
#import "CoverScene.h"


@implementation CoverScenePicture
@dynamic OriginalHash;
@dynamic OrderNumber;
@dynamic Path;
@dynamic CoverScene;

-(UIImage *)image
{
    return [UIImage imageWithContentsOfFile:self.Path];
}

@end

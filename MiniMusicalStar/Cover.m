//
//  Cover.m
//  MMS-UI
//
//  Created by Jun Kit Lee on 17/9/11.
//  Copyright (c) 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Cover.h"


@implementation Cover
@dynamic author;
@dynamic cover_of_showID;
@dynamic originalHash;
@dynamic created_date;
@dynamic title;
@dynamic Scenes;

- (void)purgeRelatedFiles
{
    [self.Scenes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [obj performSelector:@selector(purgeRelatedFiles)];
    }];
}

@end

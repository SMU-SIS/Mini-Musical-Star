//
//  Show.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Show.h"

@implementation Show

- (Show *)initWithPropertyListFile: (NSString *)pListFilePath
{
    self = [super init];
    if (self) {
        // Initialization code here. Adrian please populate the NSDictionary *data instance variable.
    }
    
    return self;
}

- (void)dealloc
{
    [data release];
}

@end

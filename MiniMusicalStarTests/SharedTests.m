//
//  SharedTests.m
//  MiniMusicalStar
//
//  Created by Adrian on 25/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SharedTests.h"

@implementation SharedTests

+ (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}


@end

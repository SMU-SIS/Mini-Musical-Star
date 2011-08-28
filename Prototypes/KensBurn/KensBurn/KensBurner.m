//
//  KensBurner.m
//  KensBurn
//
//  Created by Tommi on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KensBurner.h"
#include <stdlib.h>


@implementation KensBurner

@synthesize imageViewForKensBurning;

//these values must be modfiied after some testing. they must be constant and cannot be modified,
/* Variables for randomization */
 float minZoomScale=1.1, maxZoomScale=2.0;
 NSInteger minXMovement=-150, maxXMovement=150;
 NSInteger minYMovement=-150, maxYMovement=150;
 NSInteger minDuration=5, maxDuration=8;

float zoomScale;
NSInteger xMovement=0, yMovement=0, duration=0;


float ARC4RANDOM_MAX = 0×100000000;

- (id)initWithImageView:(UIImageView*)anImageView
{
    self = [super init];
    if (self) {
        imageViewForKensBurning = anImageView;
    }
    
    return self;
}

- (void)dealloc {
    [imageViewForKensBurning release];
    
    [super dealloc];
}

//not final product.
//final product must generate random no, to decide which set of instructions to cal
- (void)animateImageView
{
    [self randomGenerateKensBurnNumbers];
    
    [UIView animateWithDuration:duration animations:^(void) {
        CGAffineTransform zoomIn = CGAffineTransformMakeScale(zoomScale, zoomScale);
        CGAffineTransform moveRight = CGAffineTransformMakeTranslation(xMovement, yMovement);
        CGAffineTransform combo1 = CGAffineTransformConcat(zoomIn, moveRight);
        imageViewForKensBurning.transform = combo1;
    }];
    
}

- (void)randomGenerateKensBurnNumbers
{
    zoomScale = [self randFloatBetween:minZoomScale and:maxZoomScale];
    xMovement = [self getRandFrom:minXMovement to:maxXMovement];
    yMovement = [self getRandFrom:minYMovement to:maxYMovement];
    duration = [self getRandFrom:minDuration to:maxDuration];
    
    NSLog(@"%f, %i, %i, %i", zoomScale, xMovement, yMovement, duration);
}


float randomFloat()
{
    return (float)arc4random()/ARC4RANDOM_MAX;
}

float randomFloatWithRange(float a, float b)
{
    if (b < a) return b;
    if (a == b)    return a;
    return ((b-a)*randomFloat())+a;
}




- (NSInteger)getRandFrom:(NSInteger)min to:(NSInteger)max
{
    return (arc4random() % (max - min)) + min;
}


//might not be working properly
- (float)randFloatBetween:(float)low and:(float)high
{
    float diff = high - low;
    return (((float) rand() / RAND_MAX) * diff) + low;
}


@end

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

/* Range of constant values for randomization */
#define MINZOOMSCALE 1.1
#define MAXZOOMSCALE 1.8
#define MINXMOVEMENT -150
#define MAXXMOVEMENT 150
#define MINYMOVEMENT -150
#define MAXYMOVEMENT 150
#define MINDURATION 5
#define MAXDURATION 8

/* Variables to store the randomly generated numbers */
float zoomScale;
NSInteger xMovement, yMovement, duration;

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

- (void)startAnimation
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
    zoomScale = randomFloatWithRange(MINZOOMSCALE, MAXZOOMSCALE);
    xMovement = [self getRandFrom:MINXMOVEMENT to:MAXXMOVEMENT];
    yMovement = [self getRandFrom:MINYMOVEMENT to:MAXYMOVEMENT];
    duration = [self getRandFrom:MINDURATION to:MAXDURATION];
    
    //NSLog(@"Zoom Scale: %f, xMovement: %i, yMovement: %i, Duration: %i", zoomScale, xMovement, yMovement, duration);
}

#define ARC4RANDOM_MAX  4294967296

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

@end
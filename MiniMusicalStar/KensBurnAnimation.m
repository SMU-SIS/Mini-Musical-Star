//
//  KensBurnAnimation.m
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 3/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "KensBurnAnimation.h"
#include <stdlib.h>

@implementation KensBurnAnimation

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

-(CABasicAnimation*) getKensBurnAnimationForImageAtTime: (float) startTime andDuration: (float) duration
{
    [self randomGenerateKensBurnNumbers];
    
    CABasicAnimation *kensBurnAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CGAffineTransform zoomIn = CGAffineTransformMakeScale(zoomScale, zoomScale);
    CGAffineTransform moveRight = CGAffineTransformMakeTranslation(xMovement, yMovement);
    CGAffineTransform combo = CGAffineTransformConcat(zoomIn, moveRight);
    
    kensBurnAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(combo)];
    kensBurnAnimation.additive = NO;
    kensBurnAnimation.removedOnCompletion = NO;
    kensBurnAnimation.beginTime = startTime;
    kensBurnAnimation.duration = duration;
    kensBurnAnimation.fillMode = kCAFillModeBoth;
    kensBurnAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return kensBurnAnimation;
    
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
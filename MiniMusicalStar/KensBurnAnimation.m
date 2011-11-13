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
#define MAXZOOMSCALE 1.5
#define MINXMOVEMENT -100
#define MAXXMOVEMENT 100
#define MINYMOVEMENT -100
#define MAXYMOVEMENT 100
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
    kensBurnAnimation.fillMode = kCAFillModeRemoved;
    kensBurnAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return kensBurnAnimation;
    
}

-(void) addKensBurnAnimationToLayer: (CALayer*)layer withTimingsArray:(NSMutableArray*)sortedTimingsArray overDuration:(Float64)durationInSeconds
{
    for(int i =0 ; i<sortedTimingsArray.count ; i++)
    {
        float startTime = [[sortedTimingsArray objectAtIndex:i] floatValue];
        
        float duration = 0;
        
        if (i + 1 != sortedTimingsArray.count){
            duration = [[sortedTimingsArray objectAtIndex:i+1] floatValue] - startTime;
        }else{
            Float64 videoLength = durationInSeconds;
            duration = videoLength - startTime;
        }
        
        if(i==0){
            startTime = startTime + 0.1;
            duration = duration - 0.1;
        }
        
        CABasicAnimation *kensBurnAnimation = [self getKensBurnAnimationForImageAtTime:startTime andDuration:duration];
        
        [layer addAnimation:kensBurnAnimation forKey:nil];
    }
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
//
//  CustomVideoAnimations.m
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomVideoAnimations.h"

@implementation CustomVideoAnimations

+(void) addTextAnimationLayersToLayer: (CALayer*)animationLayer withTextArray:(NSMutableArray*)textFieldArray forVideoSize:(CGSize)videoSize
{
    [textFieldArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UITextField *textField = (UITextField*) obj;
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.string = textField.text;
        textLayer.font = @"Lucida Grande";
        textLayer.fontSize = 30;
        
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height);
        
        textLayer.position = CGPointMake(320, 250 -(idx * 50));
        
        [animationLayer addSublayer:textLayer];
    }];
}


+(CABasicAnimation*) getAppearAnimationAtTime:(float)startTime withDuration:(float)duration
{
    CABasicAnimation *appearAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    appearAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    appearAnimation.toValue = [NSNumber numberWithFloat:1.0];
    appearAnimation.additive = NO;
    appearAnimation.removedOnCompletion = NO;
    appearAnimation.beginTime = startTime;
    appearAnimation.duration = duration;
    appearAnimation.fillMode = kCAFillModeForwards;
    return appearAnimation;  
}

+(CABasicAnimation*) getScrollAnimationAtTime:(float)startTime withDuration:(float)duration
{
    CABasicAnimation *scrollAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    scrollAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    scrollAnimation.toValue = [NSNumber numberWithFloat:500.0];
    scrollAnimation.additive = NO;
    scrollAnimation.removedOnCompletion = NO;
    scrollAnimation.beginTime = startTime;
    scrollAnimation.duration = duration;
    scrollAnimation.fillMode = kCAFillModeForwards;
    return scrollAnimation;
}

+(CABasicAnimation*) getFadeAnimationAtTime:(float)startTime withDuration:(float)duration
{
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.additive = NO;
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.beginTime = startTime;
    fadeAnimation.duration = duration;
    fadeAnimation.fillMode = kCAFillModeForwards;
    return fadeAnimation;
}

@end

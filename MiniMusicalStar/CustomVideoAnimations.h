//
//  CustomVideoAnimations.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CustomVideoAnimations : NSObject

+(void) addTextAnimationLayersToLayer: (CALayer*)animationLayer withTextArray:(NSMutableArray*)textFieldArray forVideoSize:(CGSize)videoSize;


+(CABasicAnimation*) getAppearAnimationAtTime:(float)startTime withDuration:(float)duration;

+(CABasicAnimation*) getScrollAnimationAtTime:(float)startTime withDuration:(float)duration;

+(CABasicAnimation*) getFadeAnimationAtTime:(float)startTime withDuration:(float)duration;

@end

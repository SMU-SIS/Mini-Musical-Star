//
//  KensBurnAnimation.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 3/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface KensBurnAnimation : NSObject {
    IBOutlet UIImageView* imageViewForKensBurning;
}

@property (nonatomic, retain) UIImageView *imageViewForKensBurning;

//constructo
- (id)initWithImageView:(UIImageView*)anImageView;

- (void)startAnimation;
- (void)randomGenerateKensBurnNumbers;
- (NSInteger)getRandFrom:(NSInteger)min to:(NSInteger)max;
-(CABasicAnimation*) getKensBurnAnimationForImageAtTime: (float) startTime andDuration: (float) duration;
-(void) addKensBurnAnimationToLayer: (CALayer*)layer withTimingsArray:(NSMutableArray*)sortedTimingsArray overDuration:(Float64)durationInSeconds;
/* C methods */
float randomFloat();
float randomFloatWithRange(float a, float b);

@end
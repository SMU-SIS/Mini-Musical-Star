//
//  KensBurner.h
//  KensBurn
//
//  Created by Tommi on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KensBurner : NSObject {
    IBOutlet UIImageView* imageViewForKensBurning;
}

@property (nonatomic, retain) UIImageView *imageViewForKensBurning;

//constructor
- (id)initWithImageView:(UIImageView*)anImageView;

- (void)animateImageView;
- (void)randomGenerateKensBurnNumbers;
- (float)randFloatBetween:(float)low and:(float)high;

float randomFloat();
float randomFloatWithRange(float a, float b);

-(NSInteger)getRandFrom:(NSInteger)min to:(NSInteger)max;

@end
    
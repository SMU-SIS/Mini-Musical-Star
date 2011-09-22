//
//  KensBurner.h
//  KensBurn
//
//  Created by Tommi on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//This class helps you to implement kens burn effect on your UIImageView.
//To use this class:
//1. Use initWithImageView
//2. Call startAnimation

#import <Foundation/Foundation.h>

@interface KensBurner : NSObject {
    IBOutlet UIImageView* imageViewForKensBurning;
}

@property (nonatomic, retain) UIImageView *imageViewForKensBurning;

//constructo
- (id)initWithImageView:(UIImageView*)anImageView;

- (void)startAnimation;
- (void)randomGenerateKensBurnNumbers;
- (NSInteger)getRandFrom:(NSInteger)min to:(NSInteger)max;

/* C methods */
float randomFloat();
float randomFloatWithRange(float a, float b);

@end
//
//  ShowImages.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShowImage.h"


@implementation ShowImage

-(NSArray *)getShowImages
{
    showImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"wickedCover.jpg"], [UIImage imageNamed:@"gleeCover.jpg"], [UIImage imageNamed:@"hsmCover.jpg"], nil];
    
    return [showImages autorelease];
}

-(NSArray *)getSceneImages:(int)musical
{
    if (musical == 0) {
        sceneImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"wickedS1.jpeg"], [UIImage imageNamed:@"wickedS2.jpeg"], [UIImage imageNamed:@"wickedS3.jpeg"], [UIImage imageNamed:@"wickedS4.jpeg"], nil];
    } 
    else if (musical == 1) {
        sceneImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"gleeS1.jpeg"], [UIImage imageNamed:@"gleeS2.jpeg"], [UIImage imageNamed:@"gleeS3.jpeg"], [UIImage imageNamed:@"gleeS4.jpeg"], [UIImage imageNamed:@"gleeS5.jpeg"], nil];
    }
    else {
        sceneImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"hsmS1.jpeg"], [UIImage imageNamed:@"hsmS2.jpeg"], [UIImage imageNamed:@"hsmS3.jpeg"], nil];
    }
    
    return [sceneImages autorelease];
}

-(NSArray *)getImagesInTheScene
{
    imagesOfAScene = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"g1.png"], [UIImage imageNamed:@"g2.png"], [UIImage imageNamed:@"g3.png"], [UIImage imageNamed:@"g4.png"], [UIImage imageNamed:@"g5.png"], [UIImage imageNamed:@"g6.png"], [UIImage imageNamed:@"g7.png"], [UIImage imageNamed:@"g8.png"], nil];
    
    return [imagesOfAScene autorelease];
}

@end

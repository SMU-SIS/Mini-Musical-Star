//
//  ShowImages.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ShowImage : NSObject {
    NSArray *showImages;
    NSArray *sceneImages;
    NSArray *imagesOfAScene;
}

-(NSArray *)getShowImages;
-(NSArray *)getSceneImages:(int)musical;
-(NSArray *)getImagesInTheScene;

@end

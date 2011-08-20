//
//  ImageReplacer.h
//  PickThePhoto
//
//  Created by Tommi on 20/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageReplacer : NSObject
{
    NSMutableArray *imagesArray; //stores a pointer to the image
}

@property (nonatomic, retain) NSMutableArray *imagesArray;

- (id)initWithMutableArray:(NSMutableArray*)anImagesArray;

@end

//
//  UIImage+Resize.h
//  MusicalStar
//
//  Created by Jun Kit Lee on 21/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_Resize)
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end

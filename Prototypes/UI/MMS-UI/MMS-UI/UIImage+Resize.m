//
//  UIImage+Resize.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 21/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (UIImage_Resize)
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}
@end

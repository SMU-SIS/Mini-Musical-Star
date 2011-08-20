//
//  ChangeThePhotoViewController.h
//  ChangeThePhoto
//
//  Created by Tommi on 19/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeThePhotoViewController : UIViewController
{
    IBOutlet UIImageView *imageView;
    
    NSMutableArray *imagesArray;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) NSMutableArray *imagesArray;

-(void) replaceImage: (NSInteger*) imageIndex;
-(void) refreshImageView;

@end

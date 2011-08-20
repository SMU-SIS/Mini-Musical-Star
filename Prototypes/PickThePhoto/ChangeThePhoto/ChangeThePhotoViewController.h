//
//  ChangeThePhotoViewController.h
//  ChangeThePhoto
//
//  Created by Tommi on 19/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondViewController.h"

@interface ChangeThePhotoViewController : UIViewController
{
    IBOutlet UIImageView *imageView;
    
    NSMutableArray *imagesArray;
    
    SecondViewController *secondViewController;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) NSMutableArray *imagesArray;

@property (nonatomic, retain) SecondViewController *secondViewController;

-(void) replaceImage: (NSInteger*) imageIndex;
-(void) refreshImageView;

@end

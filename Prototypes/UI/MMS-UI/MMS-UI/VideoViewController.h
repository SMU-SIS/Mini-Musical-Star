//
//  VideoViewController.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"
#import "EditViewController.h"


@interface VideoViewController : UIViewController {
    IBOutlet UIScrollView *scrollView;
    
    UIView *options;
}

-(void)positionTheImages:(NSArray *)images;
-(void)setImageToLeftView:(UIButton *)sender;
-(void)callGraphicsOption:(NSInteger)buttonNumber;

@end

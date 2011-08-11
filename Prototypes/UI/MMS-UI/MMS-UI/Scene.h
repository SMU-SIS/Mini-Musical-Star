//
//  Scene.h
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"

@interface Scene : UIViewController{
    IBOutlet UIImageView *imageView;
    IBOutlet UIView *toggleview;
    int imageNum;
    ShowImage *menuImages;
    
    UIImageView *imageView1;
    UIImageView *imageView2;
}

@property (nonatomic, assign) int imageNum;

-(void)setImageNum:(int)num;
-(int)getImageNum;
-(IBAction)backToMenu;

-(IBAction)toggleToImage;
-(IBAction)toggleToAudio;

-(void)setToggleMenu;

@end

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
    IBOutlet UIButton *sceneButton;

    int imageNum;
    ShowImage *menuImages;
}

@property (nonatomic, assign) int imageNum;

-(void)setImageNum:(int)num;
-(int)getImageNum;
-(IBAction)backToMenu;

-(IBAction)selectScene;
-(void)fromEditToMenu;

@end

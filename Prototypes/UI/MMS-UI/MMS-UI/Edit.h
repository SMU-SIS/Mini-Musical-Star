//
//  Edit.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"
#import "AudioMenu.h"
#import "Graphics.h"

@interface Edit : UIViewController {
    IBOutlet UIScrollView *toggleView;
    IBOutlet UISegmentedControl *segControl;
    IBOutlet UIImageView *leftView;
    
    UIImageView *imageView1;
    UIImageView *imageView2;
    
    UIView *graphicsMenu;
}

-(IBAction)setToggleOption;

-(IBAction)backToScene;

-(void)setImageToLeftView:(int)imgNum;

@end

//
//  Edit.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"


@interface Edit : UIViewController {
    IBOutlet UIView *toggleView;
    IBOutlet UISegmentedControl *segControl;
    
    UIImageView *imageView1;
    UIImageView *imageView2;
    
    UIView *graphicsMenu;
}

-(IBAction)setToggleOption;

-(IBAction)backToScene;

-(UIView *)getGraphics;

@end

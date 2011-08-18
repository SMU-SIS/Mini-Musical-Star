//
//  Edit.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Scene.h"
#import "A_sampleViewController.h"

@interface Edit : UIViewController {
    IBOutlet UIView *toggleView;
    IBOutlet UISegmentedControl *segControl;
    A_sampleViewController *sampleview;
    UIImageView *imageView1;
    UIImageView *imageView2;
}

-(IBAction)setToggleOption;

-(IBAction)backToScene;
//-(IBAction)backtoMenu;

@property(retain, nonatomic) UIImageView *imageView1;
@property(retain, nonatomic) UIImageView *imageView2;
@property(retain, nonatomic) A_sampleViewController *sampleview;

@end

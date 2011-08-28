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
#import "GraphicMenu.h"
#import "FourthAttemptViewController.h"
#import "MixPlayerRecorder.h"

@interface Edit : UIViewController {
    IBOutlet UIScrollView *toggleView;
    IBOutlet UISegmentedControl *segControl;
    IBOutlet UIImageView *leftView;
    FourthAttemptViewController *audioview;

    UIView *options;
    UIScrollView *scrollView;
    
    UIView *graphicsMenu;
}

-(IBAction)setToggleOption;

-(IBAction)backToScene;

-(void)setImageToLeftView:(UIButton *)sender;

-(UIView *)graphicsView;

-(void)callGraphicsOption:(NSInteger)buttonNum;

-(void)closeOptionMenu:(id)sender;

@property(retain, nonatomic) FourthAttemptViewController *audioview;

@end
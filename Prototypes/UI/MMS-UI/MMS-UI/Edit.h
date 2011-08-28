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

@interface Edit : UIViewController {
    IBOutlet UIScrollView *toggleView;
    IBOutlet UISegmentedControl *segControl;
    IBOutlet UIImageView *leftView;
    FourthAttemptViewController *audioview;
    UIImageView *imageView;
    UIScrollView *scrollView;
    
    UIView *graphicsMenu;
}

-(IBAction)setToggleOption;

-(IBAction)backToScene;

-(void)setImageToLeftView:(id)sender;

-(UIView *)graphicsView;

-(void)callGraphicsOption:(NSInteger)buttonNum;

@property(retain, nonatomic) FourthAttemptViewController *audioview;

@end

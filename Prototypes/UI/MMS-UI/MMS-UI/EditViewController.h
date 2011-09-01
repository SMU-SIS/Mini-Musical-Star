//
//  Edit.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"
#import "AudioViewController.h"
#import "MixPlayerRecorder.h"
#import "SceneViewController.h"
#import "VideoViewController.h"

@interface EditViewController : UIViewController {
    IBOutlet UIScrollView *toggleView;
    IBOutlet UISegmentedControl *segControl;
    IBOutlet UIImageView *leftView;
    AudioViewController *audioview;
    //VideoViewController *videoView;
    
    UIView *options;
    UIScrollView *scrollView;
    
    UIView *graphicsMenu;
}

-(IBAction)setToggleOption;

-(IBAction)backToScene;

-(void)setImageToLeftView:(UIButton *)sender;
//-(void)setImageToLeftView:(UIImage *)img;

-(UIView *)graphicsView;

-(void)callGraphicsOption:(NSInteger)buttonNum;

-(void)closeOptionMenu:(id)sender;

-(EditViewController *)initWithImagesFromScene:(Scene *)aScene;


@property(retain, nonatomic) Scene *chosenScene;

@property(retain, nonatomic) AudioViewController *audioview;

@end

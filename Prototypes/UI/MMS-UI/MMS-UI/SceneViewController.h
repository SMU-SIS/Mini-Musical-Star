//
//  Scene.h
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"
#import "Show.h"

@interface SceneViewController : UIViewController{
    IBOutlet UIImageView *showCover;
    IBOutlet UIScrollView *sceneMenu;

    int imageNum;
    ShowImage *menuImages;
    ShowImage *scenes;

}

@property (nonatomic, assign) int imageNum;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Scene *chosenScene;

-(SceneViewController *)initWithScenesFromShow:(Show *)aShow;

-(void)setImageNum:(int)num;
-(int)getImageNum;
-(IBAction)backToMenu;

-(void)selectScene:(id)sender;
-(void)displaySceneImages:(NSArray *)images;

@end

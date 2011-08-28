//
//  Scene.h
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"

@interface SceneUI : UIViewController{
    IBOutlet UIButton *sceneButton;
    IBOutlet UIScrollView *sceneMenu;
}

@property (retain, nonatomic) Show *theShow;

-(SceneUI *)initWithScenesFromShow:(Show *)aShow;
-(IBAction)backToMenu;

//-(IBAction)selectScene;
-(void)selectScene:(id)sender;

@end

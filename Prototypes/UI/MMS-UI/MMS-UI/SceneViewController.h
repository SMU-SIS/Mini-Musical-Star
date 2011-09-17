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
#import "SceneEditViewController.h"
#import "Cover.h"
#import "CoverScene.h"

@interface SceneViewController : UIViewController{
    IBOutlet UIImageView *showCover;
    IBOutlet UIScrollView *sceneMenu;

    int imageNum;

}

@property (retain, nonatomic) NSManagedObjectContext *context;
@property (nonatomic, assign) int imageNum;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Scene *chosenScene;
@property (retain, nonatomic) Cover *theCover;


-(SceneViewController *)initWithScenesFromShow:(Show *)aShow andCover:(Cover *)aCover andContext:(NSManagedObjectContext *)aContext;

-(void)setImageNum:(int)num;
-(int)getImageNum;
-(IBAction)backToMenu;

-(void)selectScene:(id)sender;
-(void)displaySceneImages:(NSArray *)images;

@end

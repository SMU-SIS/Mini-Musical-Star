//
//  Scene.h
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"
#import "SceneEditViewController.h"
#import "CoversListViewController.h"
#import "Cover.h"
#import "CoverScene.h"
#import "DSActivityView.h"

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

@property (retain, nonatomic) UIButton *saveCoverButton;
@property (retain, nonatomic) UITextField *userCoverName;

@property (retain, nonatomic) CoversListViewController *coversList;
@property (retain, nonatomic) UIPopoverController *coversPopover;

-(SceneViewController *)initWithScenesFromShow:(Show *)aShow andCover:(Cover *)aCover andContext:(NSManagedObjectContext *)aContext;

-(void)selectScene:(UIButton *)sender;
-(void)displaySceneImages:(NSArray *)images;

@end

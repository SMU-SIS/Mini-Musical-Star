//
//  Scene.h
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Show;
@class Cover;
@class SceneEditViewController;
@class ExportTableViewController;
@interface SceneViewController : UIViewController
<UIPopoverControllerDelegate>

@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Cover *theCover;
@property (retain, nonatomic) IBOutlet UIImageView *showCover;
@property (retain, nonatomic) IBOutlet UIScrollView *sceneMenu;
@property (nonatomic, retain) UIBarButtonItem *exportButton;
@property (nonatomic, retain) UIPopoverController *popoverController;

-(SceneViewController *)initWithScenesFromShow:(Show *)aShow andCover:(Cover *)aCover andContext:(NSManagedObjectContext *)aContext;
- (void)loadSceneSelectionScrollView;
-(void)selectScene:(UIButton *)sender;
-(void)loadSceneEditViewController:(UIButton *)sender;
-(void)finishLoadingSceneEditViewController:(SceneEditViewController *)theController;
@end

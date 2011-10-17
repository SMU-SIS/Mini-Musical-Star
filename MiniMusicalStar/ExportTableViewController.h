//
//  ExportTableViewController.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 17/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"
#import "DSActivityView.h"
#import "AudioEditorViewController.h"
#import "ShowDAO.h"
#import "SceneUtility.h"

@interface ExportTableViewController : UITableViewController

@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) SceneUtility *theSceneUtility;

@end

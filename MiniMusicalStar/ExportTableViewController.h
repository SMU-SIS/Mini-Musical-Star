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
#import "Cover.h"

@interface ExportTableViewController : UITableViewController

@property (retain, nonatomic) NSArray *musicalArray;
@property (retain, nonatomic) NSArray *scenesArray;
@property (retain, nonatomic) NSMutableArray *exportedFilesArray;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Cover *theCover;
@property (retain, nonatomic) SceneUtility *theSceneUtility;
@property (nonatomic) __block bool exportRunning;
@property (nonatomic, retain) AVAssetExportSession *exportSession;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSString *exportFilename;
-(void) progress;
-(void) loadArrays;
- (id)initWithStyle:(UITableViewStyle)style:(Show*)theShow:(Cover*)cover;

@end

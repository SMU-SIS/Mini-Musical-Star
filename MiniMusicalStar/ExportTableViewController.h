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
#import "FacebookUploader.h"

@interface ExportTableViewController : UITableViewController
{
    FacebookUploader *mmsFacebook;
}

@property (retain, nonatomic) NSArray *musicalArray;
@property (retain, nonatomic) NSArray *scenesArray;
@property (retain, nonatomic) NSMutableArray *exportedFilesArray;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Cover *theCover;
@property (retain, nonatomic) SceneUtility *theSceneUtility;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIBarButtonItem *uploadBarButtonItem;
@property (nonatomic, retain) FacebookUploader *mmsFacebook;
@property (retain, nonatomic) NSMutableArray *tempMusicalContainer;

-(void) progress;
-(void) loadArrays;
- (id)initWithStyle:(UITableViewStyle)style:(Show*)theShow:(Cover*)cover;
- (void)uploadToFacebook;
- (void)generateMusical;

@end

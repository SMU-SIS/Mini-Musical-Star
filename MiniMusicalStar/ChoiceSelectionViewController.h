//
//  ChoiceSelectionViewController.h
//  MiniMusicalStar
//
//  Created by Wei Jie Tan on 11/10/11.
//  Copyright 2011 weijie.tan.2009@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"
#import "SceneViewController.h"
#import "Cover.h"
#import "CoversListViewController.h"
#import "ExportTableViewController.h"
#import "AlertPrompt.h"

@class SceneStripController;

@interface ChoiceSelectionViewController : UIViewController <CoversListDelegate> {
    IBOutlet UIImageView *showCover;
    IBOutlet UIButton *create;
    IBOutlet UIButton *cover;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (retain, nonatomic) Show *theShow;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) NSFetchedResultsController *frc;
@property (retain, nonatomic) NSString *coverName;
@property (nonatomic, retain) ExportTableViewController *exportTableController;
@property (nonatomic, retain) CoversListViewController *currentSelectedCoversList;
@property (nonatomic, retain) UIBarButtonItem *mediaManagementButton;
@property (retain, nonatomic) IBOutlet UILabel *showTitle;
@property (retain, nonatomic) IBOutlet UITextView *showDescription;
@property (retain, nonatomic) IBOutlet SceneStripController *sceneStripController;
@property (retain, nonatomic) IBOutlet UITableView *coversTableView;
@property (retain, nonatomic) IBOutlet UIButton *exportButton;

-(ChoiceSelectionViewController *)initWithAShowForSelection:(Show *)aShow context:(NSManagedObjectContext *)aContext;
- (void)loadSceneSelectionScrollViewWithCover:(Cover *)aCover;
-(void)createMusical;
-(IBAction)loadCoversList:(UIButton*)sender;
- (IBAction)removeScrollStrip:(id) sender;
-(IBAction)promptForCoverName:(UIButton*)sender;
- (IBAction)goToExportPage: (id)sender;

- (void)loadCoversForShow:(Show *)aShow;
-(void)selectedSavedCover;

- (void)dismissCoversList;

@end

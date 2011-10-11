//
//  MMS_UIViewController.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowDAO.h"
#import "Show.h"
#import "Cover.h"

#import "SceneViewController.h"
#import "DSActivityView.h"

@class NewOpenViewController;

@interface MenuViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    IBOutlet UIScrollView *scrollView; 

    NSMutableArray *buttonArray;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    UIView *currentSelectedMusical;
    UIViewController *currentSelectedCoversList;
}

@property (retain, nonatomic) NSArray *shows;
@property (retain, nonatomic) UIView *currentSelectedMusical;
@property (retain, nonatomic) UIViewController *currentSelectedCoversList;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)daoDownloadQueueFinished;

-(IBAction)musicalButtonWasPressed: (UIButton*)sender;

-(void)displayShowImages:(NSArray *)images;

@end

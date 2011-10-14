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
#import "ChoiceSelectionViewController.h"

#import "SceneViewController.h"
#import "DSActivityView.h"

@class NewOpenViewController;
@class UndownloadedShow;

@interface MenuViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    IBOutlet UIScrollView *scrollView; 

    NSMutableArray *buttonArray;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    UIView *currentSelectedMusical;
    UIViewController *currentSelectedCoversList;
}

@property (assign, nonatomic) NSArray *shows;
@property (retain, nonatomic) UIView *currentSelectedMusical;
@property (retain, nonatomic) UIViewController *currentSelectedCoversList;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)daoDownloadQueueFinished;
- (void)createScrollViewOfShows;
- (UIButton *)createButtonForShow:(Show *)aShow frame:(CGRect)buttonFrame;
- (UIButton *)createButtonForUndownloadedShow:(UndownloadedShow *)aShow frame:(CGRect)buttonFrame;
-(IBAction)musicalButtonWasPressed: (UIButton*)sender;

-(void)displayShowImages:(NSArray *)images;

@end

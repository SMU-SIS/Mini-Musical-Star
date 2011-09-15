//
//  MMS_UIViewController.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"
#import "ShowDAO.h"
#import "Show.h"

#import "SceneViewController.h"
#import "PlaybackViewController.h"
#import "CoverViewController.h"
#import "DSActivityView.h"
#import "HiddenView.h"

@interface MenuViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    IBOutlet UIScrollView *scrollView; 
    
    ShowImage *showImages;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (retain, nonatomic) NSArray *shows;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)daoDownloadQueueFinished;

-(IBAction)createMusical;
-(IBAction)playBackMusical;
-(IBAction)coverMusical;

-(Show *)returnCurrentSelectedShow;
-(void)displayShowImages:(NSArray *)images;

@end

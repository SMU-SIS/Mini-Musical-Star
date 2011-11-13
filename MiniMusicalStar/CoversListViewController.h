//
//  CoversListViewController.h
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 3/10/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"
#import "Cover.h"

@protocol CoversListDelegate <NSObject>
-(void) setVideosButtonTag:(int)number;
- (void)loadSceneSelectionScrollViewWithCover:(Cover *)aCover;
-(IBAction) showMediaManagement: (id)sender;

@end

@interface CoversListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (assign, nonatomic) id delegate;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) NSFetchedResultsController *frc;

- (Cover*) getSelectedCover: (NSIndexPath *)indexPath;
- (id)initWithShow:(Show *)aShow context:(NSManagedObjectContext *)aContext;
- (void)createFetchedResultsController;
- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
- (int)numberOfCovers;
@end

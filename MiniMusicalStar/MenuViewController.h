//
//  MMS_UIViewController.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewOpenViewController;
@class UndownloadedShow;
@class Show;
@class ShowDAO;

@interface MenuViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) NSMutableArray *buttonArray;
@property (retain, nonatomic) ShowDAO *showDAO;

- (void)createScrollViewOfShows;
- (UIButton *)createButtonForShow:(Show *)aShow frame:(CGRect)buttonFrame;
- (UIButton *)createButtonForUndownloadedShow:(UndownloadedShow *)aShow frame:(CGRect)buttonFrame;
- (void)downloadMusical:(UIButton *)sender;
-(void)selectMusical:(UIImageView *)musicalButton;

@end

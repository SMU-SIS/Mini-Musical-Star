//
//  MMS_UIViewController.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class NewOpenViewController;
@class UndownloadedShow;
@class Show;
@class ShowDAO;
@class VideoPlayerViewController;

@interface MenuViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    BOOL downloadRequestGotCancelled;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) IBOutlet UIButton *tutorialButton;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) NSMutableArray *buttonArray;
@property (retain, nonatomic) ShowDAO *showDAO;

- (void)createScrollViewOfShows;
- (UIButton *)createButtonForShow:(Show *)aShow frame:(CGRect)buttonFrame;
- (UIButton *)createButtonForUndownloadedShow:(UndownloadedShow *)aShow frame:(CGRect)buttonFrame;
- (void)downloadMusical:(UIButton *)sender;
- (void)cancelDownloadOfShow:(UIButton *)sender;
- (void)resetToCleanStateForPartiallyDownloadedShow:(UndownloadedShow *)aShow;
- (void)selectMusical:(UIImageView *)musicalButton;
- (IBAction) playTutorial:(id)sender;


@end

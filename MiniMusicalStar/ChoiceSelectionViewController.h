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

@interface ChoiceSelectionViewController : UIViewController{
    IBOutlet UIImageView *showCover;
    IBOutlet UIButton *create;
    IBOutlet UIButton *cover;
    
    NSManagedObjectContext *managedObjectContext;
    UIViewController *currentSelectedCoversList;
    UIView *currentSelectedMusical;
}

@property (retain, nonatomic) Show *theShow;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) UIViewController *currentSelectedCoversList;
@property (retain, nonatomic) UIView *currentSelectedMusical;
@property (retain, nonatomic) NSFetchedResultsController *frc;

@property (retain, nonatomic) IBOutlet UILabel *showTitle;
@property (retain, nonatomic) IBOutlet UITextView *showDescription;

-(ChoiceSelectionViewController *)initWithAShowForSelection:(Show *)aShow context:(NSManagedObjectContext *)aContext;

-(IBAction)createMusical:(UIButton*)sender;
-(IBAction)listCoversForMusical:(UIButton*)sender;

- (void)loadCoversForShow:(Show *)aShow;

@end

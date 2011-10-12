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

@interface ChoiceSelectionViewController : UIViewController{
    IBOutlet UIImageView *showCover;
    IBOutlet UIButton *create;
    IBOutlet UIButton *cover;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (retain, nonatomic) Show *theShow;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(ChoiceSelectionViewController *)initWithAShowForSelection:(Show *)aShow context:(NSManagedObjectContext *)aContext;

-(IBAction)createMusical:(UIButton*)sender;

@end

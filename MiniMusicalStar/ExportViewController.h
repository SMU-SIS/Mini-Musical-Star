//
//  ExportViewController.h
//  MiniMusicalStar
//
//  Created by Tommi on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"
#import "Cover.h"
#import "ExportTableViewController.h"
#import "MediaTableViewController.h"

@interface ExportViewController : UIViewController <ExportTableViewDelegate,MediaTableViewDelegate>

@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Cover *theCover;
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) ExportTableViewController *exportTableViewController;
@property (retain, nonatomic) MediaTableViewController *mediaTableViewController;

- (ExportViewController*)initWithStuff:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext;

@property (nonatomic, retain) UIColor *background;

@end

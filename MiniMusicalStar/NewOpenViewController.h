//
//  NewOpenViewController.h
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 11/10/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Show;

@interface NewOpenViewController : UIViewController

@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) NSManagedObjectContext *context;

@end

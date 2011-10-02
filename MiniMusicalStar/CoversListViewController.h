//
//  CoversListViewController.h
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 3/10/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cover.h"

@interface CoversListViewController : UITableViewController

@property (assign, nonatomic) id delegate;
@property (retain, nonatomic) NSArray *coversArray;

@end

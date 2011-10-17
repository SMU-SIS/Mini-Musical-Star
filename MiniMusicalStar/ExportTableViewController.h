//
//  ExportTableViewController.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 17/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"

@protocol ExportTableViewControllerDelegate <NSObject>

-(void)didTap:(NSString *)string;

@end

@interface ExportTableViewController : UITableViewController
{
    id delegate;
}

@property (retain, nonatomic) Show *theShow;
@property (nonatomic, assign) id<ExportTableViewControllerDelegate> delegate;

@end

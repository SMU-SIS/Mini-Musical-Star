//
//  CustomCell.h
//  PlayNewUI
//
//  Created by Tommi on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
{
    UILabel *primaryLabel;
    UILabel *secondaryLabel;
    UIImageView *myImageView;
    UITableView *tableView;
}

@property(nonatomic,retain)UILabel *primaryLabel;
@property(nonatomic,retain)UILabel *secondaryLabel;
@property(nonatomic,retain)UIImageView *myImageView;
@property(nonatomic,retain)UITableView *tableView;

@end

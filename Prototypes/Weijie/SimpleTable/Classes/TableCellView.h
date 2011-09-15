//
//  TableCellView.h
//  SimpleTable
//
//  Created by Adeem on 30/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleTableViewController.h"


@interface TableCellView : UITableViewCell {
	IBOutlet UILabel *cellText;
    IBOutlet UIButton *record;
}

- (void)setLabelText:(NSString *)_text;
-(void)setButtonTag:(int)num;
-(IBAction)pressed:(UIButton *)sender;
@end

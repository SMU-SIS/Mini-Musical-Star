//
//  TableCellView.m
//  SimpleTable
//
//  Created by Adeem on 30/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableCellView.h"


@implementation TableCellView

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

/* This set of code is being deprecciated, replaced by the above.
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}
 */


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}

- (void)setLabelText:(NSString *)_text;{
	cellText.text = _text;
}

-(void)setButtonTag:(int)num;{
    [record setTag:num];
}

-(IBAction)pressed:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    [button setBackgroundImage:[UIImage imageNamed:@"rec.png"] forState:UIControlStateNormal];
    
    NSLog(@"hehre %i", button.tag);
}
@end

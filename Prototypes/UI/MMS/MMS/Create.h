//
//  Create.h
//  MMS
//
//  Created by Weijie Tan on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuImage.h"


@interface Create : UIViewController {
    IBOutlet UIImageView *imageView;
    int imageNum;
    MenuImage *menuImages;
}

@property (nonatomic, assign) int imageNum;

-(void)setImageNum:(int)num;
-(int)getImageNum;
-(IBAction)backToMenu;

@end

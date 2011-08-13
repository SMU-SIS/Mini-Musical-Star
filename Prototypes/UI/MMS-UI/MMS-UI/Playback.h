//
//  Playback.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"


@interface Playback : UIViewController {
    IBOutlet UIImageView *playBack;
    
    int imageNum;
    ShowImage *menuImages;
}

-(void)setImageNum:(int)num;
-(int)getImageNum;
-(IBAction)backToMenu;

@end

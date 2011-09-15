//
//  NaviTestViewController.h
//  NaviTest
//
//  Created by Weijie Tan on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scene.h"

@interface NaviTestViewController : UIViewController {
    IBOutlet UINavigationController *naviController;
}

-(IBAction)toScene:(id)sender;

@end

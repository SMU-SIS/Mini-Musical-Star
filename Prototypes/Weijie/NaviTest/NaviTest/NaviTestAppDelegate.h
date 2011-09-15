//
//  NaviTestAppDelegate.h
//  NaviTest
//
//  Created by Weijie Tan on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NaviTestViewController;

@interface NaviTestAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet NaviTestViewController *viewController;

@property (nonatomic, retain) IBOutlet UINavigationController *naviController;

@end

//
//  MMSAppDelegate.h
//  MMS
//
//  Created by Weijie Tan on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMSViewController;

@interface MMSAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MMSViewController *viewController;

@end

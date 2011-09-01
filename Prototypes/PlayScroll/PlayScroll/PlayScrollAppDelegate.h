//
//  PlayScrollAppDelegate.h
//  PlayScroll
//
//  Created by Tommi on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayScrollViewController;

@interface PlayScrollAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PlayScrollViewController *viewController;

@end

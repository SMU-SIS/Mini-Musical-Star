//
//  PlayWithViewsAppDelegate.h
//  PlayWithViews
//
//  Created by Tommi on 20/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayWithViewsViewController;

@interface PlayWithViewsAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PlayWithViewsViewController *viewController;

@end

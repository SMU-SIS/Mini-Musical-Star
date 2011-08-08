//
//  SlideShowAppAppDelegate.h
//  SlideShowApp
//
//  Created by Tommi on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlideShowAppViewController;

@interface SlideShowAppAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet SlideShowAppViewController *viewController;

@end

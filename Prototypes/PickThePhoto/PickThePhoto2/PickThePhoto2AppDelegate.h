//
//  PickThePhoto2AppDelegate.h
//  PickThePhoto2
//
//  Created by Tommi on 25/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickThePhoto2ViewController;

@interface PickThePhoto2AppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PickThePhoto2ViewController *viewController;

@end

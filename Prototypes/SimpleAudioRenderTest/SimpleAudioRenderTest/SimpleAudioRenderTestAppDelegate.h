//
//  SimpleAudioRenderTestAppDelegate.h
//  SimpleAudioRenderTest
//
//  Created by Jun Kit on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimpleAudioRenderTestViewController;

@interface SimpleAudioRenderTestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet SimpleAudioRenderTestViewController *viewController;

@end

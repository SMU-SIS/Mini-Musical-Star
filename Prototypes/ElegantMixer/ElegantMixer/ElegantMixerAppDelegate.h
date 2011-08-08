//
//  ElegantMixerAppDelegate.h
//  ElegantMixer
//
//  Created by Jun Kit on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ElegantMixerViewController;

@interface ElegantMixerAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet ElegantMixerViewController *viewController;

@end

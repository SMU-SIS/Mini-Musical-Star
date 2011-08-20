//
//  PickThePhotoAppDelegate.h
//  PickThePhoto
//
//  Created by Tommi on 19/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickThePhotoViewController;

@interface PickThePhotoAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PickThePhotoViewController *viewController;

@end

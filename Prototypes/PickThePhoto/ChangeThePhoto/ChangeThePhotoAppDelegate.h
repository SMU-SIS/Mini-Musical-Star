//
//  ChangeThePhotoAppDelegate.h
//  ChangeThePhoto
//
//  Created by Tommi on 19/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChangeThePhotoViewController;

@interface ChangeThePhotoAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet ChangeThePhotoViewController *viewController;

@end

//
//  SickProjAppDelegate.h
//  SickProj
//
//  Created by Tommi on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SickProjViewController;

@interface SickProjAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet SickProjViewController *viewController;

@end

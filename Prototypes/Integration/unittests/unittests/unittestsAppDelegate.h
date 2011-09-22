//
//  UnitTestsAppDelegate.h
//  UnitTests
//
//  Created by Jun Kit Lee on 22/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UnitTestsViewController;

@interface UnitTestsAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UnitTestsViewController *viewController;

@end

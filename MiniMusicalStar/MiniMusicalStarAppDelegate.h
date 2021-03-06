//
//  MMS_UIAppDelegate.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Heatmaps/HeatmapsDelegate.h>

@class MenuViewController;

@interface MiniMusicalStarAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, HeatmapsDelegate> {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UINavigationController *naviController;
@property (nonatomic, retain) IBOutlet MenuViewController *viewController;

- (NSString *)applicationDocumentsDirectory;

@end

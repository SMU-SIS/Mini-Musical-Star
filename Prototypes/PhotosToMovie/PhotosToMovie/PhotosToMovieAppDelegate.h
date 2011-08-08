//
//  PhotosToMovieAppDelegate.h
//  PhotosToMovie
//
//  Created by Jun Kit on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotosToMovieViewController;

@interface PhotosToMovieAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PhotosToMovieViewController *viewController;

@end

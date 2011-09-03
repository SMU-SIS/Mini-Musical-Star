//
//  ShowDAO.h
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Show.h"
//#import "ASIHTTPRequest.h"

@interface ShowDAO : NSObject

+ (void)loadLocalShows;
+ (NSArray *)shows;
+ (NSArray *)imagesForShows;
+ (void)checkForNewShowsFromServer;
+ (BOOL)checkIfExistsLocally:(NSString *)showTitle;
+ (void)initiateDownloadOfShowFromServer:(NSURL *)zipFileURL andStoreInPath:(NSString *)localShowPath;
@end

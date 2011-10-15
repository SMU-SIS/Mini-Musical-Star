//
//  ShowDAO.h
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ZipArchive.h"
@class UndownloadedShow;
@class Show;
@interface ShowDAO : NSObject

+ (void)loadShowsWithDelegate:(id)aDelegate;
+ (void)loadLocalShows;
+ (Show *)loadSingleShowFromDirectoryURL:(NSURL *)showDirectoryURL;
+ (NSMutableArray *)shows;
+ (NSMutableArray *)showsNotDownloaded;
+ (NSArray *)imagesForShows;
+ (void)checkForNewShowsFromServer;
+ (BOOL)checkIfExistsLocally:(int)showID;
+ (void)downloadShow:(UndownloadedShow *)aShow progressIndicatorDelegate:(id)aDelegate;
+ (void)unzipDownloadedShowURL:(NSString *)localShowZipPath toPath:(NSString *)unzipPath;
+ (NSMutableString *)getUserDocumentDir;

@end

//
//  ShowDAO.h
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Show.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ZipArchive.h"

@interface ShowDAO : NSObject

+ (void)loadShowsWithDelegate:(id)aDelegate;
+ (void)loadLocalShows;
+ (void)loadSingleShowFromDirectoryURL:(NSURL *)showDirectoryURL;
+ (NSMutableArray *)shows;
+ (NSMutableArray *)showsNotDownloaded;
+ (NSArray *)imagesForShows;
+ (void)checkForNewShowsFromServer;
+ (BOOL)checkIfExistsLocally:(int)showID;
+ (void)initiateDownloadOfShowFromServer:(NSURL *)zipFileURL andStoreInPath:(NSString *)localShowPath;
+ (void)unzipDownloadedShowURL:(NSString *)localShowZipPath toPath:(NSString *)unzipPath;
+ (NSMutableString *)getUserDocumentDir;

@end

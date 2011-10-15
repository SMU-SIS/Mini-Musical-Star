//
//  ShowDAO.h
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UndownloadedShow;
@class Show;
@interface ShowDAO : NSObject

@property (retain, nonatomic) NSMutableArray *loadedShows;
@property (retain, nonatomic) NSMutableDictionary *activeDownloads;
@property (assign, nonatomic) id delegate;

+ (NSMutableString *)userDocumentDirectory;
- (id)initWithDelegate:(id)aDelegate;
- (void)loadLocalShows;
- (Show *)loadSingleShowFromDirectoryURL:(NSURL *)showDirectoryURL;
- (void)checkForNewShowsFromServer;
- (void)downloadShow:(UndownloadedShow *)aShow progressIndicatorDelegate:(id)aDelegate;
- (void)cancelDownloadForShow:(UndownloadedShow *)aShow;
- (BOOL)checkIfExistsLocally:(int)showID;
- (void)unzipDownloadedShowURL:(NSString *)localShowZipPath toPath:(NSString *)unzipPath;
@end

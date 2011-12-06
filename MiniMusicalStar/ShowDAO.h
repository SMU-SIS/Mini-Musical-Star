//
//  ShowDAO.h
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class UndownloadedShow;
@class Show;
@class StoreController;

@protocol ShowDAOStateDelegate <NSObject>
@required
- (void)showDAO:(id)aShowDAO didFinishLoadingShows:(NSArray *)loadedShows;

@end

@interface ShowDAO : NSObject <SKProductsRequestDelegate>

@property (retain, nonatomic) NSMutableArray *loadedShows;
@property (retain, nonatomic) NSMutableDictionary *activeDownloads;
@property (assign, nonatomic) id delegate;

+ (NSMutableString *)userDocumentDirectory;
- (void)generateUUIDInUserDefaults;
- (id)initWithDelegate:(id)aDelegate;
- (void)seedTutorialMusical;
- (void)loadLocalShows;
- (Show *)loadSingleShowFromDirectoryURL:(NSURL *)showDirectoryURL;
- (void)checkForNewShowsFromServer;
- (void)downloadShow:(UndownloadedShow *)aShow progressIndicatorDelegate:(id)aDelegate;
- (void)cancelDownloadForShow:(UndownloadedShow *)aShow;
- (BOOL)checkIfExistsLocally:(NSString *)productIdentifier;
- (void)unzipDownloadedShowURL:(NSString *)localShowZipPath toPath:(NSString *)unzipPath;

@end

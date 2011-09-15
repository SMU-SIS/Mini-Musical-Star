//
//  ShowDAO.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "ShowDAO.h"

@implementation ShowDAO

static ASINetworkQueue *downloadQueue;
static NSMutableArray *loadedShows;
static NSString *userDocumentDirectory;
static bool initialized = NO;
static id delegate;

+ (void)loadShowsWithDelegate:(id)aDelegate
{
    delegate = aDelegate;
    [self loadLocalShows];
    [self checkForNewShowsFromServer];
}

+ (void)loadLocalShows
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask ,YES);
    userDocumentDirectory = [paths objectAtIndex:0];
    NSLog(@"document directory is %@\n", userDocumentDirectory);
    
    NSString *showsDirectory = [userDocumentDirectory stringByAppendingString:@"/shows"];    
    
    //create it
    [manager createDirectoryAtPath:showsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    
    //list the directory structure
    NSArray *showsDirectoryListing = [manager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:showsDirectory] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    loadedShows = [[NSMutableArray alloc] initWithCapacity:showsDirectoryListing.count]; 
    
    //read the showMetaData.plist file for every Show
    [showsDirectoryListing enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *showDirectoryURL = (NSURL *)obj;
        [self loadSingleShowFromDirectoryURL:showDirectoryURL];
    }];
    
    initialized = YES;
}

+ (void)loadSingleShowFromDirectoryURL:(NSURL *)showDirectoryURL
{
    NSLog(@"showDirectoryURL: %@",showDirectoryURL);
    
    //get a reference to showMetaData.plist url
    NSURL *metadataURL = [showDirectoryURL URLByAppendingPathComponent:@"showMetaData.plist"];
    NSString *metadataString = [metadataURL path];
    NSLog(@"metadataString is %@\n", metadataString);
    
    Show *show = [[Show alloc] initShowWithPropertyListFile:metadataString atPath:showDirectoryURL];
    [loadedShows addObject:show];
    [show release];
}

+ (NSArray *)shows
{
    if (!initialized) [self loadLocalShows];
    
    return loadedShows;
}

+ (NSArray *)imagesForShows
{
    if (!initialized) [self loadLocalShows];
    
    NSMutableArray *imagesArray = [[NSMutableArray alloc] initWithCapacity:loadedShows.count];
    [loadedShows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Show *show = (Show *)obj;
        [imagesArray addObject:show.coverPicture];
        
    }];
    
    return imagesArray;
}

+ (void)checkForNewShowsFromServer
{
    downloadQueue = [[ASINetworkQueue alloc] init];
    [downloadQueue setDelegate:delegate];
    [downloadQueue setQueueDidFinishSelector:@selector(daoDownloadQueueFinished)];
    
    NSString *urlStr = [[NSString alloc] 
                        initWithFormat:@"http://dl.dropbox.com/u/23645/shows.plist?seedVar=%f", 
                        (float)random()/RAND_MAX];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *root = [[NSDictionary alloc] initWithContentsOfURL:url];
    NSLog(@"the dictionary is %@\n", root);
    
    NSArray *showCatalogue = [root objectForKey:@"shows"];
    
    //find shows that are not in already local, then download
    [showCatalogue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *showInCatalogue = (NSDictionary *)obj;
        int showID = [[showInCatalogue objectForKey:@"id"] intValue];
        NSString *showTitleZip = [[showInCatalogue objectForKey:@"title"] stringByAppendingPathExtension:@"zip"];
        if (![self checkIfExistsLocally:showID])
        {
            NSURL *showDownloadLocation = [NSURL URLWithString:[showInCatalogue objectForKey:@"zip_url"]];
            NSString *downloadPath = [[userDocumentDirectory stringByAppendingPathComponent:@"shows"] stringByAppendingPathComponent:showTitleZip];
            [self initiateDownloadOfShowFromServer:showDownloadLocation andStoreInPath:downloadPath];
        }
    }];
    
    if (downloadQueue.requestsCount > 0)
    {
        NSLog(@"Number of requests in the downloadQueue is %i\n", downloadQueue.requestsCount);
        [downloadQueue go];
    }
    
    else
    {
        [downloadQueue release];
        [delegate performSelectorOnMainThread:@selector(daoDownloadQueueFinished) withObject:nil waitUntilDone:NO];
    }
}

+ (void)initiateDownloadOfShowFromServer:(NSURL *)zipFileURL andStoreInPath:(NSString *)localShowPath
{
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:zipFileURL];
    [request setDownloadDestinationPath:localShowPath];
    [request setCompletionBlock:^{
        NSLog(@"Download finished! Unzipping show...\n");
        [self unzipDownloadedShowURL:localShowPath toPath:[localShowPath stringByDeletingPathExtension]];
        [self loadSingleShowFromDirectoryURL:
            [NSURL fileURLWithPath:[localShowPath stringByDeletingPathExtension]]];
        NSLog(@"Show at %@ loaded\n", [localShowPath stringByDeletingPathExtension]);
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Download Error: %@\n", error);
    }];
    
    [downloadQueue addOperation:request];
    
}
            
+ (BOOL)checkIfExistsLocally:(int)showID
{
    for (int i = 0; i < loadedShows.count; i++)
    {
        Show *aShow = [loadedShows objectAtIndex:i];
        NSLog(@"showID is [%i] and aShow.showID is [%i]", showID, aShow.showID); 
        if (showID == aShow.showID)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (void)unzipDownloadedShowURL:(NSString *)localShowZipPath toPath:(NSString *)unzipPath
{
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    [zipArchive UnzipOpenFile:localShowZipPath];
    [zipArchive UnzipFileTo:unzipPath overWrite:YES];
    [zipArchive UnzipCloseFile];
    [zipArchive release];
    
    //delete the zip file
    unlink([localShowZipPath cStringUsingEncoding:NSUTF8StringEncoding]);
}
            

@end

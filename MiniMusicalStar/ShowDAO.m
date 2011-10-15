//
//  ShowDAO.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "ShowDAO.h"
#import "UndownloadedShow.h"
#import "Show.h"

@implementation ShowDAO

static ASINetworkQueue *downloadQueue;
static NSMutableArray *loadedShows;
static NSMutableArray *showsNotDownloaded;
static NSString *userDocumentDirectory;
static bool initialized = NO;
static id delegate;

+ (void)loadShowsWithDelegate:(id)aDelegate
{
    delegate = aDelegate;
    [self loadLocalShows];
    [self checkForNewShowsFromServer];
    
    //uncomment this when switching back
    //[delegate performSelectorOnMainThread:@selector(daoDownloadQueueFinished) withObject:nil waitUntilDone:NO];
}

+ (NSMutableString *)getUserDocumentDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *path = [NSMutableString stringWithString:[paths objectAtIndex:0]];
    return path;
}

+ (void)loadLocalShows
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    userDocumentDirectory = [self getUserDocumentDir];
    NSLog(@"document directory is %@\n", userDocumentDirectory);
    
    NSString *showsDirectory = [userDocumentDirectory stringByAppendingString:@"/shows"];    
    
    //create it
    [manager createDirectoryAtPath:showsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    
    //list the directory structure
    NSArray *showsDirectoryListing = [manager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:showsDirectory] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    loadedShows = [[NSMutableArray alloc] initWithCapacity:showsDirectoryListing.count]; 
    
    //read the showMetaData.plist file for every Show and get a Show object out of it, and add it to the array
    [showsDirectoryListing enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *showDirectoryURL = (NSURL *)obj;
        Show *newShow = [self loadSingleShowFromDirectoryURL:showDirectoryURL];
        [loadedShows addObject:newShow];
    }];
    
    initialized = YES;
}

+ (Show *)loadSingleShowFromDirectoryURL:(NSURL *)showDirectoryURL
{
    
    //get a reference to showMetaData.plist url
    NSURL *metadataURL = [showDirectoryURL URLByAppendingPathComponent:@"metadata.plist"];
    NSString *metadataString = [metadataURL path];
    
    Show *show = [[Show alloc] initShowWithPropertyListFile:metadataString atPath:showDirectoryURL];
    return [show autorelease];
}

+ (NSMutableArray *)shows
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
    
    NSString *urlStr = [[NSString alloc] 
                        initWithFormat:@"http://dl.dropbox.com/u/23645/shows.plist?seedVar=%f", 
                        (float)random()/RAND_MAX];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *root = [[NSDictionary alloc] initWithContentsOfURL:url];
    
    NSArray *showCatalogue = [root objectForKey:@"shows"];
    
    //find shows that are not in already local, then create UndownloadShow objects for them
    [showCatalogue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *showInCatalogue = (NSDictionary *)obj;
        int showID = [[showInCatalogue objectForKey:@"id"] intValue];
        if (![self checkIfExistsLocally:showID])
        {
            //don't download now, just give the user an option to download
            UndownloadedShow *undownloadedShow = [[UndownloadedShow alloc] init];
            
            undownloadedShow.showID = showID;
            undownloadedShow.title = [showInCatalogue objectForKey:@"title"];
            undownloadedShow.downloadURL = [NSURL URLWithString:[showInCatalogue objectForKey:@"zip_url"]];
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[showInCatalogue objectForKey:@"cover-photo-url"]]];
            
            undownloadedShow.coverImage = [UIImage imageWithData:imageData];
            
            [loadedShows addObject:undownloadedShow];
        }
    }];
}

+ (void)downloadShow:(UndownloadedShow *)aShow progressIndicatorDelegate:(id)aDelegate
{
    //destination path
    NSString *destinationPath = [[[[self getUserDocumentDir] stringByAppendingPathComponent:@"shows"] stringByAppendingPathComponent:aShow.title] stringByAppendingPathExtension:@"zip"];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:aShow.downloadURL];
    [request setDownloadProgressDelegate:aDelegate];
    [request setShowAccurateProgress:YES];
    
    [request setDownloadDestinationPath:destinationPath];
    [request setCompletionBlock:^{
        
        //remove the progress bar
        [(UIView *)aDelegate removeFromSuperview];
        
        //then we do the decompressing...
        [self unzipDownloadedShowURL:destinationPath toPath:[destinationPath stringByDeletingPathExtension]];
        Show *newShow = [self loadSingleShowFromDirectoryURL:[NSURL fileURLWithPath:[destinationPath stringByDeletingPathExtension]]];
        
        //we replace the old show in the array with this new show
        int undownloadedShowIndex = [loadedShows indexOfObject:aShow];
        [loadedShows replaceObjectAtIndex:undownloadedShowIndex withObject:newShow];
        
        //we don't have to update the array ourselves as KVO on MenuViewController will do that for us :)
    }];
    
    [request setFailedBlock:^{
        NSLog(@"Download of show failed. No internet access?");
    }];
    
    //start the request asynchronously
    [request startAsynchronous];
}
            
+ (BOOL)checkIfExistsLocally:(int)showID
{
    for (int i = 0; i < loadedShows.count; i++)
    {
        Show *aShow = [loadedShows objectAtIndex:i];
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
    
    //delete the resource fork
    NSString *resourceFork = [unzipPath stringByAppendingPathComponent:@"__MACOSX"];
    [[NSFileManager defaultManager] removeItemAtPath:resourceFork error:nil];
}
            

@end

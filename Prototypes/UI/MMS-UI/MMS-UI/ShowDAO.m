//
//  ShowDAO.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "ShowDAO.h"

@implementation ShowDAO

static NSMutableArray *loadedShows;
static NSString *userDocumentDirectory;
static bool initialized = NO;

+ (void)loadShows
{
    [self loadLocalShows];
    [self checkForNewShowsFromServer];
    [self loadLocalShows];
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
        NSLog(@"showDirectoryURL: %@",showDirectoryURL);
        
        //get a reference to showMetaData.plist url
        NSURL *metadataURL = [showDirectoryURL URLByAppendingPathComponent:@"showMetaData.plist"];
        NSString *metadataString = [metadataURL path];
        NSLog(@"metadataString is %@\n", metadataString);
        
        Show *show = [[Show alloc] initShowWithPropertyListFile:metadataString atPath:showDirectoryURL];
        [loadedShows addObject:show];
        [show release];
        
    }];
    
    initialized = YES;
}

+ (NSArray *)shows
{
    if (!initialized) [self loadLocalShows];
    
    return [loadedShows autorelease];
}

+ (NSArray *)imagesForShows
{
    if (!initialized) [self loadLocalShows];
    
    NSMutableArray *imagesArray = [[NSMutableArray alloc] initWithCapacity:loadedShows.count];
    [loadedShows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Show *show = (Show *)obj;
        [imagesArray addObject:show.coverPicture];
        
    }];
    
    return [imagesArray autorelease];
}

+ (void)checkForNewShowsFromServer
{
    NSString *urlStr = [[NSString alloc] 
                        initWithFormat:@"http://dl.dropbox.com/u/23645/shows.plist?seedVar=%f", 
                        (float)random()/RAND_MAX];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *root = [[NSDictionary alloc] initWithContentsOfURL:url];
    
    NSArray *showCatalogue = [root objectForKey:@"shows"];
    
    //find shows that are not in already local, then download
    [showCatalogue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *showInCatalogue = (NSDictionary *)obj;
        NSString *showTitle = [showInCatalogue objectForKey:@"title"];
        if (![self checkIfExistsLocally:showTitle])
        {
            NSURL *showDownloadLocation = [NSURL URLWithString:[showInCatalogue objectForKey:@"zip_url"]];
            NSString *downloadPath = [[userDocumentDirectory stringByAppendingPathComponent:@"shows"] stringByAppendingPathComponent:showTitle];
            [self initiateDownloadOfShowFromServer:showDownloadLocation andStoreInPath:downloadPath];
        }
    }];
}

+ (void)initiateDownloadOfShowFromServer:(NSURL *)zipFileURL andStoreInPath:(NSString *)localShowPath
{
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:zipFileURL];
    [request setDownloadDestinationPath:localShowPath];
    [request setCompletionBlock:^{
        NSLog(@"Download finished!");
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Download Error: %@\n", error);
    }];
    
}
            
+ (BOOL)checkIfExistsLocally:(NSString *)showTitle
{
    for (int i = 0; i < loadedShows.count; i++)
    {
        Show *aShow = [loadedShows objectAtIndex:i];
        if ([showTitle isEqualToString:aShow.title])
        {
            return YES;
        }
    }
    
    return NO;
}
            

@end

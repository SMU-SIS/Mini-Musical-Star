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
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ZipArchive.h"

@implementation ShowDAO
@synthesize loadedShows, activeDownloads, delegate;

- (void)dealloc
{
    [loadedShows release];
    [activeDownloads release];
    [super dealloc];
}

- (id)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self)
    {
        self.delegate = aDelegate;
        
        [self seedTutorialMusical];
        [self loadLocalShows];
        [self checkForNewShowsFromServer];
        
        self.activeDownloads = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (NSMutableString *)userDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *path = [NSMutableString stringWithString:[paths objectAtIndex:0]];
    return path;
}

- (void)seedTutorialMusical
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];

    NSString *showsDirectory = [[ShowDAO userDocumentDirectory] stringByAppendingString:@"/shows"];
    
    //create the shows directory (if it's not already there)
    [manager createDirectoryAtPath:showsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    
    BOOL isDirectory = YES;
    if (![manager fileExistsAtPath:@"Howling Dog" isDirectory:&isDirectory])
    {
        //then seed the tutorial
        NSString *howlingDogZip = [[NSBundle mainBundle] pathForResource:@"howling_dog" ofType:@"zip"];
        [self unzipDownloadedShowURL:howlingDogZip toPath:[showsDirectory stringByAppendingPathComponent:@"Howling Dog"]];
    }
}

- (void)loadLocalShows
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSLog(@"document directory is %@\n", [ShowDAO userDocumentDirectory]);
    
    NSString *showsDirectory = [[ShowDAO userDocumentDirectory] stringByAppendingString:@"/shows"];    

    //list the directory structure
    NSArray *showsDirectoryListing = [manager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:showsDirectory] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    self.loadedShows = [NSMutableArray arrayWithCapacity:showsDirectoryListing.count]; 
    
    //read the showMetaData.plist file for every Show and get a Show object out of it, and add it to the array
    [showsDirectoryListing enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *showDirectoryURL = (NSURL *)obj;
        Show *newShow = [self loadSingleShowFromDirectoryURL:showDirectoryURL];
        [self.loadedShows addObject:newShow];
    }];
}

- (Show *)loadSingleShowFromDirectoryURL:(NSURL *)showDirectoryURL
{
    
    //get a reference to showMetaData.plist url
    NSURL *metadataURL = [showDirectoryURL URLByAppendingPathComponent:@"metadata.plist"];
    NSString *metadataString = [metadataURL path];
    
    Show *show = [[Show alloc] initShowWithPropertyListFile:metadataString atPath:showDirectoryURL];
    return [show autorelease];
}

- (void)checkForNewShowsFromServer
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
            
            //use a placeholder image if there is no coverImage
            if (!undownloadedShow.coverImage)
            {
                undownloadedShow.coverImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"musical_placeholder" ofType:@"png"]];
            }
            
            [self.loadedShows addObject:undownloadedShow];
        }
    }];
}

- (void)downloadShow:(UndownloadedShow *)aShow progressIndicatorDelegate:(id)aDelegate
{
    //destination path
    NSString *destinationPath = [[[[ShowDAO userDocumentDirectory] stringByAppendingPathComponent:@"shows"] stringByAppendingPathComponent:aShow.title] stringByAppendingPathExtension:@"zip"];
    
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
        
        //this thing caused me HOURS OF GRIEF. no one told me that NSMutableArray was not KVO-compliant, must use mutableArrayValueForKey!
        [[self mutableArrayValueForKey:@"loadedShows"] replaceObjectAtIndex:undownloadedShowIndex withObject:newShow];
        
        //MenuViewController is KVO-ing loadedShows, she (haha! I gave it a gender!) will update the scrollview automatically
        
        //remove myself from the dictionary
        [activeDownloads removeObjectForKey:aShow.downloadURL];

    }];
    
    [request setFailedBlock:^{
        NSLog(@"Download of show failed. No internet access? Or probably user cancelled it?");
        [activeDownloads removeObjectForKey:aShow.downloadURL];
        
        //inform the MenuViewController that the download has failed to allow her to update the UI
        [delegate performSelectorOnMainThread:@selector(resetToCleanStateForPartiallyDownloadedShow:) withObject:aShow waitUntilDone:NO];
    }];
    
    //start the request asynchronously
    [request startAsynchronous];
    
    //add the request to the activeDownloads dictionary so that we can refer to it later on
    [activeDownloads setObject:request forKey:aShow.downloadURL];
}

- (void)cancelDownloadForShow:(UndownloadedShow *)aShow
{
    ASIHTTPRequest *request = [activeDownloads objectForKey:aShow.downloadURL];
    [request cancel];
}
            
- (BOOL)checkIfExistsLocally:(int)showID
{
    for (int i = 0; i < self.loadedShows.count; i++)
    {
        Show *aShow = [self.loadedShows objectAtIndex:i];
        if (showID == aShow.showID)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)unzipDownloadedShowURL:(NSString *)localShowZipPath toPath:(NSString *)unzipPath
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

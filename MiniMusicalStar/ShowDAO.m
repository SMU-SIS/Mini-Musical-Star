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
#import "SBJson.h"
#import "StoreController.h"

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
        [self checkForNewShowsFromServer]; //this will talk to App Store for IAP, will return asynchronously so must handle it
        
        self.activeDownloads = [NSMutableDictionary dictionary];
        
        //check if we have a uuid, if not generate one for the user
        NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
        if (!uuid)
        {
            [self generateUUIDInUserDefaults];
        }
    }
    
    return self;
}

+ (NSMutableString *)userDocumentDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *path = [NSMutableString stringWithString:[paths objectAtIndex:0]];
    return path;
}

- (void)generateUUIDInUserDefaults
{
    NSString *uuid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    
    //save it into the user defaults
    [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"uuid"];
    
}

- (void)seedTutorialMusical
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];

    NSString *showsDirectory = [[ShowDAO userDocumentDirectory] stringByAppendingString:@"/shows"];
    
    //create the shows directory (if it's not already there)
    [manager createDirectoryAtPath:showsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    
    BOOL isDirectory = YES;
    if (![manager fileExistsAtPath:[showsDirectory stringByAppendingPathComponent:@"Howling Dog"] isDirectory:&isDirectory])
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
    // get the list of purchaseable shows returned as an array of product identifiers
    __block ASIHTTPRequest *showsRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://mmsmusicalstore.appspot.com/shows"]];
    [showsRequest setCompletionBlock:^{
        NSString *responseString = [showsRequest responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *responseArray = [parser objectWithString:responseString];
        
        [parser release];
        
        //create an array of product identifiers
        NSMutableSet *productIdentifiers = [NSSet setWithArray:responseArray];
        
        __block NSMutableSet *undownloadedProductIdentifiers = [NSMutableSet set];
        
        //filter out those that already exists on localhost
        [productIdentifiers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            if (![self checkIfExistsLocally:(NSString *)obj])
            {
                [undownloadedProductIdentifiers addObject:obj];
            }
        }];
        
        if (undownloadedProductIdentifiers.count > 0)
        {
            SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
            productsRequest.delegate = self;
            
            [productsRequest start];
        }
        
        else
        {
            NSLog(@"undownloadProductIdentifiers count is 0");
            if([self.delegate respondsToSelector:@selector(showDAO:didFinishLoadingShows:)])
            {
                [self.delegate showDAO:self didFinishLoadingShows:self.loadedShows];
            }
        }
        
    }];
    
    [showsRequest setFailedBlock:^{
        NSLog(@"Cannot communicate with content server. Moving on...");
        
        if([self.delegate respondsToSelector:@selector(showDAO:didFinishLoadingShows:)])
        {
            [self.delegate showDAO:self didFinishLoadingShows:self.loadedShows];
        }
    }];
    
    [showsRequest startAsynchronous];
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *storeProducts = response.products;
    if (response.invalidProductIdentifiers.count > 0)
    {
        NSLog(@"The invalid products are %@", response.invalidProductIdentifiers);
    }
    
    /*
     SKProduct:
     localizedDescription
     localizedTitle
     price
     priceLocale
     productIdentifier
     */
    
    [storeProducts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        SKProduct *skProduct = (SKProduct *)obj;
        
        //create UndownloadShow objects for all of them
        UndownloadedShow *newShow = [[UndownloadedShow alloc] init];
        
        newShow.skProduct = skProduct;
        newShow.showHash = skProduct.productIdentifier;
        newShow.title = skProduct.localizedTitle;
        newShow.showDescription = skProduct.localizedDescription;
        newShow.price = skProduct.price;
        newShow.downloadURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://mmsmusicalstore.appspot.com/shows/%@/download", skProduct.productIdentifier]];
        
        //grab the new show's cover image from our server
        NSString *coverImageString = [NSString stringWithFormat:@"http://mmsmusicalstore.appspot.com/shows/%@/cover_image", skProduct.productIdentifier];
        NSURL *coverImageURL = [NSURL URLWithString:coverImageString];
        //NSData *coverImageData = [NSData dataWithContentsOfURL:coverImageUEL options:NSData error:<#(NSError **)#>
        NSData *coverImageData = [NSData dataWithContentsOfURL:coverImageURL]; //this needs error handling
        
        newShow.coverImage = [UIImage imageWithData:coverImageData];
        
        [loadedShows addObject:newShow];
        
    }];
    
    [request autorelease];
    
    if([self.delegate respondsToSelector:@selector(showDAO:didFinishLoadingShows:)])
    {
        [self.delegate showDAO:self didFinishLoadingShows:self.loadedShows];
    }
    
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
            
- (BOOL)checkIfExistsLocally:(NSString *)productIdentifier

{
    for (int i = 0; i < self.loadedShows.count; i++)
    {
        Show *aShow = [self.loadedShows objectAtIndex:i];
        if ([productIdentifier isEqualToString:aShow.showHash])
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

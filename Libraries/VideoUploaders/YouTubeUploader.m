//
//  YouTubeUploader.m
//  MiniMusicalStar
//
//  Created by Tommi on 23/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "YouTubeUploader.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataEntryPhotoAlbum.h"
#import "GDataEntryPhoto.h"
#import "GDataFeedPhoto.h"
#import "GDataEntryYouTubeUpload.h"

#import "GDataYouTubeConstants.h"

@interface YouTubeUploader (PrivateMethods)
//- (void)updateUI;
//
//- (void)fetchEntryImageURLString:(NSString *)urlString;
//
//- (GDataEntryBase *)selectedEntry;
//- (void)fetchAllEntries;
//- (void)uploadVideoFile;
//- (void)restartUpload;
//
//- (GDataFeedYouTubeVideo *)entriesFeed;
//- (void)setEntriesFeed:(GDataFeedYouTubeVideo *)feed;
//
//- (NSError *)entriesFetchError;
//- (void)setEntriesFetchError:(NSError *)error;
//
//- (GDataServiceTicket *)entriesFetchTicket;
//- (void)setEntriesFetchTicket:(GDataServiceTicket *)ticket;
//
//- (NSString *)entryImageURLString;
//- (void)setEntryImageURLString:(NSString *)str;
//
//- (GDataServiceTicket *)uploadTicket;
//- (void)setUploadTicket:(GDataServiceTicket *)ticket;
//
//- (NSURL *)uploadLocationURL;
//- (void)setUploadLocationURL:(NSURL *)url;
//
//- (GDataServiceGoogleYouTube *)youTubeService;
//
//- (void)ticket:(GDataServiceTicket *)ticket
//hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
//ofTotalByteCount:(unsigned long long)dataLength;
//
//- (void)fetchStandardCategories;
@end


@implementation YouTubeUploader

- (void)uploadVideoFile {
    
    
    NSString *devKey = @"AI39si6jvKKhixI_WBcgVtGeWafmfxyzawb2Cfq44TXRRdAZB35iLmb-g_toRr11oXoXMFAhiYLRGjz4FNLsmxNpz21KZyo1-w";
    
    GDataServiceGoogleYouTube *service = [self youTubeService];
    [service setYouTubeDeveloperKey:devKey];
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    
    // load the file data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mov"];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSString *filename = [path lastPathComponent];
    
    // gather all the metadata needed for the mediaGroup
    NSString *titleStr = @"mms test";
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
    
    NSString *categoryStr = @"Education";
    GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr];
    [category setScheme:kGDataSchemeYouTubeCategory];
    
    NSString *descStr = @"mms uploaded video";
    GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
    
    NSString *keywordsStr = @"mini musical star";
    GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];
    
    //BOOL isPrivate = ([mPrivateCheckbox state] == NSOnState);
    BOOL isPrivate = NO;
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [mediaGroup setMediaTitle:title];
    [mediaGroup setMediaDescription:desc];
    [mediaGroup addMediaCategory:category];
    [mediaGroup setMediaKeywords:keywords];
    [mediaGroup setIsPrivate:isPrivate];
    
    NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path
                                               defaultMIMEType:@"video/mov"];
    
    // create the upload entry with the mediaGroup and the file
    GDataEntryYouTubeUpload *entry;
    entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
                                                    fileHandle:fileHandle
                                                      MIMEType:mimeType
                                                          slug:filename];
    
    //commented away codes which shows progress
    //SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    //[service setServiceUploadProgressSelector:progressSel];
    
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByInsertingEntry:entry
                                      forFeedURL:url
                                        delegate:self
                               didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
    [self setUploadTicket:ticket];
    
    // To allow restarting after stopping, we need to track the upload location
    // URL. The location URL will be a different address than the upload URL that
    // is used to start a new// upload.
    //
    // For compatibility with systems that do not support Objective-C blocks
    // (iOS 3 and Mac OS X 10.5), the location URL may also be obtained in the
    // progress callback as ((GTMHTTPUploadFetcher *)[ticket objectFetcher]).locationURL
    // 
    //    GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[ticket objectFetcher];
    //    [uploadFetcher setLocationChangeBlock:^(NSURL *url) {
    //        [self setUploadLocationURL:url];
    //        [self updateUI];
    //    }];
    
    //[self updateUI];
    
    NSLog(@"here here i am here");
}

#pragma mark -

// get a YouTube service object
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleYouTube *)youTubeService {
    
    static GDataServiceGoogleYouTube* service = nil;
    
    if (!service) {
        service = [[GDataServiceGoogleYouTube alloc] init];
        
        [service setShouldCacheResponseData:YES];
        [service setServiceShouldFollowNextLinks:YES];
        [service setIsServiceRetryEnabled:YES];
    }
    
    NSString *devKey = @"AI39si6jvKKhixI_WBcgVtGeWafmfxyzawb2Cfq44TXRRdAZB35iLmb";
    [service setYouTubeDeveloperKey:devKey];
    [service setUserAgent:@"Mini Musical Star"];
    [service setUserCredentialsWithUsername:@"giantmusicalstar@gmail.com" password:@"thebiggiant"];
    
    return service;
}



#pragma mark -
// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
    if (error == nil) {
        // tell the user that the add worked
        //[self displayAlert:@"Uploaded" format:@"Uploaded video: %@",[[videoEntry title] stringValue]];
        NSLog(@"tell the user that the add worked");
        
        // refetch the current entries, in case the list of uploads
        // has changed
        //  [self fetchAllEntries];
    } else {
        //[self displayAlert:@"Upload failed"
        //format:@"Upload failed: %@", error];
        NSLog(@"tell the user that the add failed");
        
    }
    // [mUploadProgressIndicator setDoubleValue:0.0];
    
    [self setUploadTicket:nil];
    //[self updateUI];
}

#pragma mark Setters and Getters

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
    [mUploadTicket release];
    mUploadTicket = [ticket retain];
}

@end

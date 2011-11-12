//
//  YouTubeUploaderViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 31/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "YouTubeUploaderViewController.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataEntryYouTubeUpload.h"
#import "GDataYouTubeConstants.h"

@interface YouTubeUploaderViewController (PrivateMethods)
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

@implementation YouTubeUploaderViewController

@synthesize delegate;

@synthesize videoNSURL;
@synthesize videoTitle;
@synthesize videoDescription;

//from xib
@synthesize centerView;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize statusLabel;
@synthesize uploadProgressView;
@synthesize okButton;

#pragma mark - init and dealloc

- (id)initWithProperties:(NSURL*)aVideoNSURL title:(NSString*)aTitle description:(NSString*)aDescription 
{
    self = [super initWithNibName:@"YouTubeUploaderViewController" bundle:nil];
    if (self) {
        self.videoNSURL = aVideoNSURL;
        self.videoTitle = aTitle;
        self.videoDescription = aDescription;
        
        uploadHasCompleted = NO;
        uploadWasStarted = NO;
        userHasCancelled = NO;
    }
    return self;
}

- (void)dealloc
{
    //from init
    [videoNSURL release];
    [videoTitle release];
    [videoDescription release];
    
    //from xib
    [okButton release];
    [centerView release];
    [passwordTextField release];
    [usernameTextField release];
    [statusLabel release];
    [uploadProgressView release];
    
    //release youtube objects
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.passwordTextField setSecureTextEntry:YES];
    self.usernameTextField.text = @"giantmusicalstar@gmail.com";
    self.passwordTextField.text = @"thebiggiant";
    self.uploadProgressView.progress = 0;
    self.statusLabel.text = @"";
    [self.okButton setTitle:@"UPLOAD" forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)upload
{
    NSString *devKey = @"AI39si6jvKKhixI_WBcgVtGeWafmfxyzawb2Cfq44TXRRdAZB35iLmb-g_toRr11oXoXMFAhiYLRGjz4FNLsmxNpz21KZyo1-w";
    
    GDataServiceGoogleYouTube *service = [self youTubeService];
    [service setYouTubeDeveloperKey:devKey];
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];
    
    // load the file data
    NSString *path = [self.videoNSURL path];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSString *filename = [path lastPathComponent];
    
    // gather all the metadata needed for the mediaGroup
    NSString *titleStr = self.videoTitle;
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
    
    NSString *categoryStr = @"Education";
    GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr];
    [category setScheme:kGDataSchemeYouTubeCategory];
    
    NSString *descStr = self.videoDescription;
    GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
    
    NSString *keywordsStr = @"mini musical star ios ipad";
    GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];
    
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
    
    SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    [service setServiceUploadProgressSelector:progressSel];
    
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByInsertingEntry:entry
                                      forFeedURL:url
                                        delegate:self
                               didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
    [self setUploadTicket:ticket];
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
    
    NSArray *userCredentialsArray = [self getUserCredentials];
    [service setUserCredentialsWithUsername:[userCredentialsArray objectAtIndex:0] password:[userCredentialsArray objectAtIndex:1]];
    
    return service;
}

#pragma mark - call backs

// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
    if (error == nil) {
        //[self displayAlert:@"Uploaded" format:@"Uploaded video: %@",[[videoEntry title] stringValue]];
        NSLog(@"The upload to youtube has succeeded. View at www.youtube.com/giantmusicalstar");
        
        self.okButton.enabled = YES;
        self.okButton.titleLabel.text = @"OK";
        
        // refetch the current entries, in case the list of uploads
        // has changed
        //  [self fetchAllEntries];
    } else {
        
        if (error.code == 403) {
            //The upload has failed with Error Domain=com.google.GDataServiceDomain Code=403 "The operation couldn’t be completed. (com.google.GDataServiceDomain error 403.)" UserInfo=0x8af9560 {Error=BadAuthentication, error=BadAuthentication}
            
        
        } else {
            //handle everything else
            
            
            
        }
        
        
        NSLog(@"The upload has failed with %@", error);
    }
    
    [self setUploadTicket:nil];
}

// progress callback, update the progress view
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead ofTotalByteCount:(unsigned long long)dataLength 
{
    self.uploadProgressView.progress = (double)numberOfBytesRead/(double)dataLength;
}

#pragma mark Setters and Getters

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
    [mUploadTicket release];
    mUploadTicket = [ticket retain];
}

#pragma mark instance methods

- (NSArray*)getUserCredentials
{    
    NSArray *userCredentialsArray = [NSArray arrayWithObjects:usernameTextField.text, passwordTextField.text, nil];
    return userCredentialsArray;
}

- (void)startUpload
{
    //check if the textboxs are filled
    
    [self upload];
    
    self.statusLabel.text = @"Uploading...";
    [self.okButton setTitle:@"CANCEL" forState:UIControlStateNormal];
}

- (void)cancelUpload
{
    [mUploadTicket cancelTicket];
    [self setUploadTicket:nil];
    
    self.uploadProgressView.progress = 0;
    self.statusLabel.text = @"Cancelled...";
    [self.okButton setTitle:@"CLOSE" forState:UIControlStateNormal];
}


#pragma mark - IBAction methods

- (IBAction)okButtonIsPressed
{       
    if ([self.okButton.titleLabel.text isEqualToString:@"UPLOAD"]) {
        [self startUpload];
        self.okButton.titleLabel.text = @"CANCEL";
        
    } else if ([self.okButton.titleLabel.text isEqualToString:@"CANCEL"]) {
        [self cancelUpload];
    
    } else if ([self.okButton.titleLabel.text isEqualToString:@"CLOSE"]) {

        if (uploadHasCompleted) {
            [delegate youTubeUploadSuccess];
        } else {
            [delegate youTubeUploadNotSuccessful];
        }
    }
    
}

@end

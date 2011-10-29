//
//  AudioEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "AudioEditorViewController.h"
#import "Audio.h"
#import "MiniMusicalStarUtilities.h"
#import <AVFoundation/AVFoundation.h>
#import "ShowDAO.h"

@implementation AudioEditorViewController
@synthesize thePlayer, theScene, theCoverScene, context;
@synthesize tracksForView, tracksForViewNSURL;
@synthesize trackTableView, recordImage, mutedImage, unmutedImage, trashbinImage, showLyricsImage;
@synthesize lyricsScrollView, lyricsLabel;
@synthesize currentRecordingURL, currentRecordingAudio;
@synthesize playPauseButton;
@synthesize arrayOfReplaceableAudios;
@synthesize playButtonImage;
@synthesize pauseButtonImage;
@synthesize recordingImage;

- (void)dealloc
{
    NSLog(@"%p deallocating now", self);
    [self deRegisterFromNSNotifcationCenter];
    [self.theCoverScene removeObserver:self forKeyPath:@"Audio"];
    
    [thePlayer stop];
    [thePlayer release];
    [theScene release];
    [theCoverScene release];
    [context release];
    
    [tracksForView release];
    [tracksForViewNSURL release];
    
    [trackTableView release];
    [recordImage release];
    [mutedImage release];
    [unmutedImage release];
    [trashbinImage release];
    [showLyricsImage release];
    [playButtonImage release];
    [pauseButtonImage release];
    
    [lyricsScrollView release];
    [lyricsLabel release];
    
    [currentRecordingURL release];
    [currentRecordingAudio release];
    
    [playPauseButton release];
    
    [arrayOfReplaceableAudios release];
    
    
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (AudioEditorViewController *)initWithScene:(Scene *)aScene andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext andPlayPauseButton:(UIButton*)aPlayPauseButton
{
    self = [super init];
    NSLog(@"INIT %p", self);
    if (self)
    {
        self.theScene = aScene;
        self.theCoverScene = aCoverScene;
        self.context = aContext;
        self.playPauseButton = aPlayPauseButton;
        
//        [self.titleBanner setImage:];
//        UIImageView *clipBoardImage = [[UIImageView alloc] initWithImage:];
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"softboard" ofType:@"png"]]];
        [self.view setBackgroundColor:background];
        
        
        isPlaying = NO;
        isRecording = NO;
        
        currentRecordingIndex = -1;
        
        tracksForView = [[NSMutableArray alloc] initWithCapacity:1];
        tracksForViewNSURL = [[NSMutableArray alloc] initWithCapacity:1];
        
        [self performSelector:@selector(consolidateArrays)];
        [self consolidateReplaceableAudios];

        [self drawLyricsView];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //KVO the Audio NSSet
    [self.theCoverScene addObserver:self forKeyPath:@"Audio" options:0 context:@"NewCoverTrackAdded"];
    
//    self.view.backgroundColor = [UIColor clearColor];
    
    trackTableView = [[UITableView alloc] initWithFrame:CGRectMake(30, 50, 500, 480) style:UITableViewStylePlain];
    
    trackTableView.delegate = self;
    trackTableView.tag = 0;
	trackTableView.dataSource = self;
    trackTableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:trackTableView];
    
    trackTableView.separatorColor = [UIColor clearColor];
    
    //load images
    recordImage = [UIImage imageNamed:@"record.png"];
    mutedImage = [UIImage imageNamed:@"muted.png"];
    unmutedImage = [UIImage imageNamed:@"unmuted.png"];
    trashbinImage = [UIImage imageNamed:@"trashbin.png"];
    showLyricsImage = [UIImage imageNamed:@"lyrics_button.png"];
    playButtonImage = [UIImage imageNamed:@"play.png"];
    pauseButtonImage = [UIImage imageNamed:@"pause.png"];
    recordingImage = [UIImage imageNamed:@"recording.png"];
    
    //load first replaceable audio's lyrics
    if (arrayOfReplaceableAudios != nil && [arrayOfReplaceableAudios count] != 0) {
        Audio *anAudio = (Audio*) [arrayOfReplaceableAudios objectAtIndex:0];
        [self loadLyrics:anAudio.lyrics];
    }
       
    //Applying autosave here
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autosaveWhenContextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
}

-(void)autosaveWhenContextDidChange:(NSNotification*)notification
{
    NSError *thisError;
    [context save:&thisError];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.theCoverScene removeObserver:self forKeyPath:@"Audio"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - UITableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

// We will only have 1 section, so don't change the value here.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   
    return self.theScene.audioTracks.count + self.theCoverScene.Audio.count;
}

#define TRACK_CELL_WIDTH 500
#define TRACK_CELL_HEIGHT 180
#define TRACK_CELL_RIGHT 350    //500-150

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *trackNameLabel;
    UIButton *recordOrTrashButton;
    UIButton *muteOrUnmuteButton;
    UIButton *showLyricsButton;

    //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:[indexPath row]];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"track.png"]];
        cell.contentView.backgroundColor = background;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        //label for track name
        trackNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 300, 30)];
        trackNameLabel.backgroundColor = [UIColor clearColor];
        trackNameLabel.textColor = [UIColor blackColor];
        trackNameLabel.textAlignment =  UITextAlignmentCenter;
        [trackNameLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:30]];
        [cell.contentView addSubview:trackNameLabel];
        trackNameLabel.tag = 1;
        [trackNameLabel release];
        
        //button for record and trash
        recordOrTrashButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 105, 50, 50)];
        [cell.contentView addSubview:recordOrTrashButton];
        recordOrTrashButton.tag = 2;
        [recordOrTrashButton release];
        
        //button for mute and unmute
        muteOrUnmuteButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 105, 50, 50)];
        [cell.contentView addSubview:muteOrUnmuteButton];
        muteOrUnmuteButton.tag = 3;
        [muteOrUnmuteButton release];
        
        //button to show lyrics
        showLyricsButton = [[UIButton alloc] initWithFrame:CGRectMake(300, 105, 50, 50)];
        [cell.contentView addSubview:showLyricsButton];
        showLyricsButton.tag = 4;
        [showLyricsButton release];
        
        [recordOrTrashButton addTarget:self action:@selector(recordOrTrashButtonIsPressed:) 
                      forControlEvents:UIControlEventTouchDown];
        [muteOrUnmuteButton addTarget:self action:@selector(muteOrUnmuteButtonIsPressed:) 
                     forControlEvents:UIControlEventTouchDown];
        [showLyricsButton addTarget:self action:@selector(showLyricsButtonIsPressed:) 
                   forControlEvents:UIControlEventTouchDown];
    }
    
    //start configuring...
    
    trackNameLabel = (UILabel*)[cell.contentView viewWithTag:1];
    trackNameLabel.text = [audioForRow valueForKey:@"title"]; //set the name of the track
    
    recordOrTrashButton = (UIButton*)[cell.contentView viewWithTag:2];
    muteOrUnmuteButton = (UIButton*)[cell.contentView viewWithTag:3];
    showLyricsButton = (UIButton*)[cell.contentView viewWithTag:4];
    
    if ([audioForRow isKindOfClass:[Audio class]]) {
        if ([(NSNumber *)[audioForRow valueForKey:@"replaceable"] boolValue]) {
            
            if (isRecording && [indexPath row] == currentRecordingIndex) {
                [recordOrTrashButton setImage:recordingImage forState:UIControlStateNormal];
            } else {
                [recordOrTrashButton setImage:recordImage forState:UIControlStateNormal];
            }
            
            [showLyricsButton setImage:showLyricsImage forState:UIControlStateNormal];
        } else {
            [recordOrTrashButton setImage:nil forState:UIControlStateNormal];
            [showLyricsButton setImage:nil forState:UIControlStateNormal];
        }
        
        if (![thePlayer busNumberIsMuted:[indexPath row]]) {
            [muteOrUnmuteButton setImage:unmutedImage forState:UIControlStateNormal];
        } else {
            [muteOrUnmuteButton setImage:mutedImage forState:UIControlStateNormal];
        }
               
    } else { //if CoverAudio        
        [recordOrTrashButton setImage:trashbinImage forState:UIControlStateNormal];
        
        if (![thePlayer busNumberIsMuted:[indexPath row]]) {
            [muteOrUnmuteButton setImage:unmutedImage forState:UIControlStateNormal];
        } else {
            [muteOrUnmuteButton setImage:mutedImage forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

//This method is for you to set the height of the table view.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRACK_CELL_HEIGHT;
}

#pragma mark - IBAction events

- (void)muteOrUnmuteButtonIsPressed:(UIButton *)sender
{    
    int busNumber = [self getTableViewRow:sender];
    
    if ([thePlayer busNumberIsMuted:busNumber]) {
        [thePlayer unmuteBusNumber:busNumber]; 
    } else {
        [thePlayer muteBusNumber:busNumber];
    }
    
    [trackTableView reloadData];
}

- (void)recordOrTrashButtonIsPressed:(UIButton*)sender
{    
    int row = -1;
    
    if (isRecording == YES) {        
        UIAlertView *recordButtonHitWhenRecordingAlert = [[UIAlertView alloc] initWithTitle:@"Opps!" message:@"You are not supposed to hit me when recording!" delegate:nil cancelButtonTitle:@"I'm sorry!" otherButtonTitles:nil];
        [recordButtonHitWhenRecordingAlert show];
        [recordButtonHitWhenRecordingAlert release];
        return;
    }
    
    row = [self getTableViewRow:sender];
    
     //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:row];
    
    if ([audioForRow isKindOfClass:[CoverSceneAudio class]]) {
        //if this is a recorded track, delete
        [self trashCoverAudio:row];
        return;
    } else if ([audioForRow isKindOfClass:[Audio class]]) {
        
        Audio *audio = (Audio*)audioForRow;
        NSNumber *isAudioReplaceable = audio.replaceable;
        
        if ([isAudioReplaceable intValue] == 0) {
            //if the audio track is cannot be replaced
            return;
        }
        
        currentRecordingIndex = row;
        
        //if the audiotrack can be replaced, start recording
        [self startCoverAudioRecording:row];
    }
}

- (void)showLyricsButtonIsPressed:(UIButton*)sender
{
    int row = [self getTableViewRow:sender];
    
    //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:row];
    Audio *audio = (Audio*)audioForRow;
    
    [self loadLyrics:[audio lyrics]];
}

#pragma mark - instance methods for player

- (void)playPauseButtonIsPressed
{
    if (isPlaying == YES && isRecording == NO) { //if the player is playing
        //is playing
        [self.thePlayer stop];
        [self.playPauseButton setImage:playButtonImage forState:UIControlStateNormal];
        
        isPlaying = NO;    
        isRecording = NO;   //to be safe
        
    } else if (isPlaying == NO && isRecording == YES) { //if the player is recording
    
        //is recording
        if (!stopButtonPressWhenRecordingWarningHasDisplayed) {
            UIAlertView *stopWhenRecordingAlertView = [[[UIAlertView alloc] initWithTitle:@"Stop?" message:@"Do you realy want to stop? :(" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
            stopWhenRecordingAlertView.tag = 1;
            [stopWhenRecordingAlertView show];

            return;
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
               
        [self.thePlayer seekTo:0];
        [self.thePlayer stop];
        [self.playPauseButton setImage:playButtonImage forState:UIControlStateNormal];
        stopButtonPressWhenRecordingWarningHasDisplayed = NO;   //reset
        
        isPlaying = NO;    
        isRecording = NO;   //to be safe
        currentRecordingIndex = -1;
        
        if (!thePlayer.stoppedBecauseReachedEnd) {
            //if file exists delete the file first
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtURL:currentRecordingURL error:nil];
        }
        
        //clear values
        currentRecordingAudio = nil;
        currentRecordingURL = nil;
    }
    else //player is neither playing or recording
    {
        //if the play pause button is press, we only expect it to be playing
        isPlaying = YES;    
        isRecording = NO;
        
        [self.thePlayer play];
        [self.playPauseButton setImage:pauseButtonImage forState:UIControlStateNormal];
    }
    
    [trackTableView reloadData];
}

- (void)reInitPlayer
{
    if (self.thePlayer != nil) {
        [self.thePlayer release];
    }
    
    thePlayer = [[MixPlayerRecorder alloc] initWithAudioFileURLs:self.tracksForViewNSURL];
    [self.thePlayer seekTo:0];
    [self.thePlayer stop];
}

- (void)giveMePlayPauseButton:(UIButton*)aButton
{
    self.playPauseButton = aButton;
}

#pragma mark - instance methods

- (void)startCoverAudioRecording:(int)indexInConsolidatedAudioTracksArray
{
    //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:indexInConsolidatedAudioTracksArray];
    
    isRecording = YES;
    
    //reload the tableviewcell
    [trackTableView reloadData];
    
    /* start recording once we determine it is a original track */
    
    //added self. to ensure it is being memory managed by the synthesized accessors
    self.currentRecordingAudio = (Audio*)audioForRow;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *userDocumentDirectory = [ShowDAO userDocumentDirectory];
    NSString *uniqueFilename = [MiniMusicalStarUtilities getUniqueFilenameWithoutExt];
    
    NSString *audioCoverFilepath = [userDocumentDirectory stringByAppendingFormat:@"/%@.caf", uniqueFilename];    //we are going to use .caf files because i am going to encode in IMA4
    
    NSURL *fileURL = [NSURL fileURLWithPath:audioCoverFilepath];
    [fileManager removeItemAtURL:fileURL error:nil];    //if file exists delete the file first
    
    self.currentRecordingURL = fileURL;
    
    [thePlayer stop];
    [thePlayer seekTo:0];
    [thePlayer stop];
    
    //start recording using MixPlayerRecorder
    [thePlayer enableRecordingToFile:fileURL];
    [thePlayer play];
    
    [self registerNotifications];
}

- (void)trashCoverAudio:(int)indexInConsolidatedAudioTracksArray
{
    id audioForRow = [tracksForView objectAtIndex:indexInConsolidatedAudioTracksArray];
    
    if ([audioForRow isKindOfClass:[Audio class]]) {
        NSLog(@"Trying to delete an audio track, crazy.");
        return;
    }
    
    CoverSceneAudio *audioToBeRemoved = (CoverSceneAudio*)audioForRow;
    NSURL *urlOfAudioToBeRemoved = [NSURL fileURLWithPath:audioToBeRemoved.path];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if (![fileManager removeItemAtURL:urlOfAudioToBeRemoved error:&error]) {
        NSLog(@"I tried to delete the audio file but failed: %@", error);
    }
    
    [self.theCoverScene removeAudioObject:audioToBeRemoved];
    [self consolidateArrays];
    [trackTableView reloadData];
}

- (void)recordingIsCompleted
{
    isRecording = NO;
      
    CoverSceneAudio *newCoverSceneAudio = [NSEntityDescription insertNewObjectForEntityForName:@"CoverSceneAudio" inManagedObjectContext:context];
    newCoverSceneAudio.title = currentRecordingAudio.title;
    newCoverSceneAudio.path = [currentRecordingURL path];
    newCoverSceneAudio.OriginalHash = currentRecordingAudio.hash;
    [self.theCoverScene addAudioObject:newCoverSceneAudio];

    [self.playPauseButton setImage:playButtonImage forState:UIControlStateNormal];
    
    currentRecordingAudio = nil;
    currentRecordingURL = nil;
    currentRecordingIndex = -1;
    
    [trackTableView reloadData];
}

- (bool)isRecording
{
    return isRecording;
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingIsCompleted) name:kMixPlayerRecorderPlaybackStopped object:nil];
}

- (void)deRegisterFromNSNotifcationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (int)getTableViewRow:(UIButton*)sender
{
    UITableViewCell *trackCell = (UITableViewCell*)sender.superview.superview;
    UITableView *tableView = (UITableView*)[trackCell superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:trackCell];
    return indexPath.row;
}

#pragma mark - instance methods for the audio and coveraudio arrays

- (NSArray*)getExportAudioURLs
{
    NSMutableArray *mutableArrayOfAudioURLs = [NSMutableArray arrayWithCapacity:1]; //don't know how big it will be, just start with 1 
    
    [tracksForView enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {        
        if ([obj isKindOfClass:[Audio class]])
        {
            Audio *anAudio = (Audio*)obj;
            NSURL *audioURL = [NSURL fileURLWithPath:anAudio.path];
            
            //add only if the audio is not muted
            if ([thePlayer busNumberIsMuted:idx] == NO) {
                [mutableArrayOfAudioURLs addObject:audioURL];                
            }
            
        } else if ([obj isKindOfClass:[CoverSceneAudio class]]) {
            CoverSceneAudio *anCoverSceneAudio = (CoverSceneAudio*)obj;
            NSURL *audioURL = [NSURL fileURLWithPath:anCoverSceneAudio.path];
            
            //add only if the audio is not muted
            if ([thePlayer busNumberIsMuted:idx] == NO) {
                [mutableArrayOfAudioURLs addObject:audioURL];
            }
        }
        
    }];
    
    NSArray *arrayOfAudioURLs = [[[NSArray alloc] initWithArray:mutableArrayOfAudioURLs] autorelease];
    
    return arrayOfAudioURLs;
}

- (void)consolidateArrays
{       
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.tracksForView removeAllObjects];
    [self.tracksForViewNSURL removeAllObjects];
    
    
    [self.theScene.audioTracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.tracksForView addObject:obj];
    }];
    
    [self.theCoverScene.Audio enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.tracksForView addObject:obj];
    }];
    
    [self.tracksForView enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Audio *anAudio = (Audio*)obj;
        NSString *path = anAudio.path;
        [self.tracksForViewNSURL addObject:[NSURL fileURLWithPath:path]];
    }];
    
    [self reInitPlayer];    
}

- (void)consolidateReplaceableAudios
{
    self.arrayOfReplaceableAudios = [NSMutableArray arrayWithCapacity:1];
    
    [self.theScene.audioTracks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[Audio class]]) {
            Audio *anAudio = (Audio*)obj;
            
            if ([anAudio.replaceable intValue] == 1) {
                [self.arrayOfReplaceableAudios addObject:anAudio];
            }
        }
    }];
}

#pragma mark - instance methods for gui

/* constants related to displaying lyrics */
#define LYRICS_VIEW_WIDTH 460 //the entire width of the landscape screen
#define LYRICS_VIEW_HEIGHT 530
#define LYRICS_VIEW_X 520
#define LYRICS_VIEW_Y 30

- (void) drawLyricsView
{
    [self createLyricsScrollView];
    [self createLyricsLabel];
    
    //[lyricsScrollView addSubview:lyricsLabel];
    [self.view addSubview:lyricsScrollView];
}

- (void)loadLyrics:(NSString*)someLyrics
{
    if (lyricsLabel != nil) {
        [lyricsLabel removeFromSuperview];
        [lyricsLabel release];
    }
    
    [self createLyricsLabel];
    [lyricsScrollView addSubview:lyricsLabel];
    
    
    CGRect lyricsLabelFrame = lyricsLabel.bounds; //get the CGRect representing the bounds of the UILabel
    
    lyricsLabelFrame.size = [someLyrics sizeWithFont:lyricsLabel.font constrainedToSize:CGSizeMake(LYRICS_VIEW_WIDTH-20, 100000) lineBreakMode:lyricsLabel.lineBreakMode]; //get a CGRect for dynamically resizing the label based on the text.
    
    lyricsLabel.frame = CGRectMake(30, 60, lyricsLabel.frame.size.width-100, lyricsLabelFrame.size.height); //set the new size of the label, we are only changing the height
    
    [lyricsScrollView setContentSize:CGSizeMake(lyricsLabel.frame.size.width, lyricsLabelFrame.size.height)]; //set content size of scroll view using calculated size of the text on the label
    
    lyricsLabel.text = someLyrics;
}

- (UIScrollView*)createLyricsScrollView {
    lyricsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(LYRICS_VIEW_X, LYRICS_VIEW_Y, LYRICS_VIEW_WIDTH, LYRICS_VIEW_HEIGHT)]; 
    
    //configure the lyrics scroll view
    lyricsScrollView.directionalLockEnabled = YES;
    lyricsScrollView.showsHorizontalScrollIndicator = NO;
    lyricsScrollView.showsVerticalScrollIndicator = YES;
    lyricsScrollView.bounces = NO;
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed: @"note_for_lyrics.png"]];
    [lyricsScrollView setBackgroundColor:background];
    
    return lyricsScrollView;
}

- (UILabel*)createLyricsLabel {
    lyricsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LYRICS_VIEW_WIDTH, LYRICS_VIEW_HEIGHT)];
    
    //configure the lyrics label
    lyricsLabel.lineBreakMode = UILineBreakModeWordWrap; //line break, word wrap
	lyricsLabel.numberOfLines = 0; //0 - dynamic ngit umber of lines
    [lyricsLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:24]];
    lyricsLabel.textColor = [UIColor blackColor];
    lyricsLabel.textAlignment =  UITextAlignmentCenter;
    lyricsLabel.backgroundColor = [UIColor clearColor];
    
    return lyricsLabel;
}


#pragma mark - UIAlertViewDelegate Protocol methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            //user pressed yes
            stopButtonPressWhenRecordingWarningHasDisplayed = YES;
            [self playPauseButtonIsPressed];
        } else if (buttonIndex == 0) {
            //user pressed no
            stopButtonPressWhenRecordingWarningHasDisplayed = NO;   //reset to default value
        }
    }
}

#pragma mark - KVO callbacks

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)changeContext
{    
    NSString *kvoContext = (NSString *)changeContext;
    if ([kvoContext isEqualToString:@"NewCoverTrackAdded"]) {
        [self performSelector:@selector(consolidateArrays)];
        [trackTableView reloadData];
    }
}

@end

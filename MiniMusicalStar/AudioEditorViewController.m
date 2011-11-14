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
#import "ShowDAO.h"
#import "Cue.h"
#import "MixPlayerRecorder.h"
#import "Scene.h"
#import "CoverScene.h"
#import "CoverSceneAudio.h"
#import "CueController.h"
#import "DSActivityView.h"

@implementation AudioEditorViewController
@synthesize recordingStatusLabel;
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
@synthesize delegate;
@synthesize tutorialButton;
@synthesize cueController,cueView, cueButtonImage;

- (void)dealloc
{
    [self deRegisterFromNSNotifcationCenter];
    [self.theCoverScene removeObserver:self forKeyPath:@"Audio"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [cueController deregisterNotifications];
    
    [tutorialButton release];
    
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
    [cueButtonImage release];
    
    [lyricsScrollView release];
    [lyricsLabel release];
    
    [currentRecordingURL release];
    [currentRecordingAudio release];
    
    [playPauseButton release];
    
    [arrayOfReplaceableAudios release];
    
    [recordingStatusLabel release];
    
    [cueController release];
    [cueView release];
    
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
    if (self)
    {
        self.theScene = aScene;
        self.theCoverScene = aCoverScene;
        self.context = aContext;
        self.playPauseButton = aPlayPauseButton;
        
//        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"softboard.png"]];
//        
//        [self.view setBackgroundColor:background];
        
        [self updatePlayerStatus:NO AndRecordingStatus:NO];
        
        currentRecordingIndex = -1;
        
        self.tracksForView = [[NSMutableArray alloc] initWithCapacity:1];
        self.tracksForViewNSURL = [[NSMutableArray alloc] initWithCapacity:1];
        
        [self performSelector:@selector(consolidateArrays)];
        [self consolidateReplaceableAudios];
        
        //load the cueController
        self.cueController = [[CueController alloc] initWithAudioArray: self.tracksForView];
        self.cueController.delegate = self;

        [self drawLyricsView];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //KVO the Audio NSSet
    [self.theCoverScene addObserver:self forKeyPath:@"Audio" options:0 context:@"NewCoverTrackAdded"];
    
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
    cueButtonImage = [UIImage imageNamed:@"audiocues.png"];
    
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
    
    [cueController deregisterNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - cues
- (void)setCueButton:(BOOL)shouldShow forTrackIndex:(NSUInteger)trackIndex
{
    //get the table row corresponding to the current track
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:trackIndex inSection:0];
    UITableViewCell *theCell = [trackTableView cellForRowAtIndexPath:indexPath];
    UIButton *showCueButton = (UIButton *)[theCell.contentView viewWithTag:5];
    
    [showCueButton setHidden:!shouldShow];
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
    UIButton *showCueButton;
    UILabel *muteUnmuteLabel;
    UILabel *recordRecordingLabel;
    UILabel *showHideLyricsLabel;
    //UILabel *showCuesLabel;

    //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:[indexPath row]];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"track.png"]];
        cell.contentView.backgroundColor = background;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        int xShift = 30;
        
        //label for track name
        trackNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30+xShift, 20, 300, 30)];
        trackNameLabel.backgroundColor = [UIColor clearColor];
        trackNameLabel.textColor = [UIColor blackColor];
        trackNameLabel.textAlignment =  UITextAlignmentCenter;
        [trackNameLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:30]];
        [cell.contentView addSubview:trackNameLabel];
        trackNameLabel.tag = 1;
        [trackNameLabel release];
        
        //button for record and trash
        recordOrTrashButton = [[UIButton alloc] initWithFrame:CGRectMake(200+xShift, 105, 50, 50)];
        [cell.contentView addSubview:recordOrTrashButton];
        recordOrTrashButton.tag = 2;
        [recordOrTrashButton release];
        
        //button for mute and unmute
        muteOrUnmuteButton = [[UIButton alloc] initWithFrame:CGRectMake(100+xShift, 105, 50, 50)];
        [cell.contentView addSubview:muteOrUnmuteButton];
        muteOrUnmuteButton.tag = 3;
        [muteOrUnmuteButton release];
        
        //button to show lyrics
        showLyricsButton = [[UIButton alloc] initWithFrame:CGRectMake(300+xShift, 105, 50, 50)];
        [cell.contentView addSubview:showLyricsButton];
        
        showLyricsButton.tag = 4;
        [showLyricsButton release];
        
        //button to show cue
        showCueButton = [[UIButton alloc] initWithFrame:CGRectMake(400+xShift, 105, 50, 50)];
        [showCueButton setHidden:YES];
        [cell.contentView addSubview:showCueButton];
        showCueButton.tag = 5;
        [showCueButton release];
        
        [recordOrTrashButton addTarget:self action:@selector(recordOrTrashButtonIsPressed:) 
                      forControlEvents:UIControlEventTouchDown];
        [muteOrUnmuteButton addTarget:self action:@selector(muteOrUnmuteButtonIsPressed:) 
                     forControlEvents:UIControlEventTouchDown];
        [showLyricsButton addTarget:self action:@selector(showLyricsButtonIsPressed:) 
                   forControlEvents:UIControlEventTouchDown];
        [showCueButton addTarget:self action:@selector(showCueButtonIsPressed:)
                forControlEvents:UIControlEventTouchDown];
        
        //label for mute and unmute
        muteUnmuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(100+xShift-15, 150, 80, 15)];
        muteUnmuteLabel.font = [UIFont systemFontOfSize:10];
        muteUnmuteLabel.textAlignment = UITextAlignmentCenter;
        [cell.contentView addSubview:muteUnmuteLabel];
        muteUnmuteLabel.tag = 6;
        [muteUnmuteLabel release];
        
        //label for record and trash
        recordRecordingLabel = [[UILabel alloc] initWithFrame:CGRectMake(200+xShift-15, 150, 80, 15)];
        recordRecordingLabel.font = [UIFont systemFontOfSize:10];
        recordRecordingLabel.textAlignment = UITextAlignmentCenter;
        [cell.contentView addSubview:recordRecordingLabel];
        recordRecordingLabel.tag = 7;
        [recordRecordingLabel release];

        //label for show and hide lyrics label
        showHideLyricsLabel = [[UILabel alloc] initWithFrame:CGRectMake(300+xShift-15, 150, 80, 15)];
        showHideLyricsLabel.font = [UIFont systemFontOfSize:10];
        showHideLyricsLabel.textAlignment = UITextAlignmentCenter;
        [cell.contentView addSubview:showHideLyricsLabel];
        showHideLyricsLabel.tag = 8;
        [showHideLyricsLabel release];

//        showCuesLabel = [[UILabel alloc] initWithFrame:CGRectMake(100+xShift-15, 150, 80, 15)];
//        showCuesLabel.font = [UIFont systemFontOfSize:10];
//        showCuesLabel.backgroundColor = [UIColor blueColor];
//        showCuesLabel.textAlignment = UITextAlignmentCenter;
//        [cell.contentView addSubview:showCuesLabel];
//        showCuesLabel.tag = 9;
//        [showCuesLabel release];
    }
    
    //start configuring...
    
    trackNameLabel = (UILabel*)[cell.contentView viewWithTag:1];
    trackNameLabel.text = [audioForRow valueForKey:@"title"]; //set the name of the track
    
    recordOrTrashButton = (UIButton*)[cell.contentView viewWithTag:2];
    muteOrUnmuteButton = (UIButton*)[cell.contentView viewWithTag:3];
    showLyricsButton = (UIButton*)[cell.contentView viewWithTag:4];
    showCueButton = (UIButton*)[cell.contentView viewWithTag:5];
    muteUnmuteLabel = (UILabel*)[cell.contentView viewWithTag:6];
    recordRecordingLabel = (UILabel*)[cell.contentView viewWithTag:7];
    showHideLyricsLabel = (UILabel*)[cell.contentView viewWithTag:8];
    
    if ([audioForRow isKindOfClass:[Audio class]]) {
        if ([(NSNumber *)[audioForRow valueForKey:@"replaceable"] boolValue]) {
            
            if ([self isRecording] && [indexPath row] == currentRecordingIndex) {
                [recordOrTrashButton setImage:recordingImage forState:UIControlStateNormal];
                recordRecordingLabel.text = @"Recording";
            } else {
                [recordOrTrashButton setImage:recordImage forState:UIControlStateNormal];
                recordRecordingLabel.text = @"Record";
            }
            
            [showLyricsButton setImage:showLyricsImage forState:UIControlStateNormal];
            showHideLyricsLabel.text = @"Show lyrics";
            
            [showCueButton setImage:cueButtonImage forState:UIControlStateNormal];
            

        } else {
            [recordOrTrashButton setImage:nil forState:UIControlStateNormal];
            recordRecordingLabel.text = @"";
            [showLyricsButton setImage:nil forState:UIControlStateNormal];
            showHideLyricsLabel.text = @"";
        }
        
        if (![thePlayer busNumberIsMuted:[indexPath row]]) {
            [muteOrUnmuteButton setImage:unmutedImage forState:UIControlStateNormal];
            muteUnmuteLabel.text = @"Mute";

        } else {
            [muteOrUnmuteButton setImage:mutedImage forState:UIControlStateNormal];
            muteUnmuteLabel.text = @"Unmute";
        }
               
    } else { //if CoverAudio        
        [recordOrTrashButton setImage:trashbinImage forState:UIControlStateNormal];
        recordRecordingLabel.text = @"Delete track";
        
        if (![thePlayer busNumberIsMuted:[indexPath row]]) {
            [muteOrUnmuteButton setImage:unmutedImage forState:UIControlStateNormal];
            muteUnmuteLabel.text = @"Mute";
        } else {
            [muteOrUnmuteButton setImage:mutedImage forState:UIControlStateNormal];
            muteUnmuteLabel.text = @"Unmute";
        }
        
        [showLyricsButton setImage:nil forState:UIControlStateNormal];
        showHideLyricsLabel.text = @"";
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
    
    if ([self isRecording] == YES) {        
        UIAlertView *recordButtonHitWhenRecordingAlert = [[UIAlertView alloc] initWithTitle:@"Opps!" message:@"You are not supposed to hit me when recording!" delegate:nil cancelButtonTitle:@"I'm sorry!" otherButtonTitles:nil];
        [recordButtonHitWhenRecordingAlert show];
        [recordButtonHitWhenRecordingAlert release];
        return;
    }
    
    row = [self getTableViewRow:sender];
    
     //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:row];
    
    if ([audioForRow isKindOfClass:[CoverSceneAudio class]]) {
        
        //check if player is playing
        if ([self isPlaying] == YES) {
            [self.thePlayer stop];
            [self updatePlayerStatus:NO AndRecordingStatus:NO];
        }
        
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
        
        [self.playPauseButton setImage:pauseButtonImage forState:UIControlStateNormal];
        
        //if the audiotrack can be replaced, start recording
        [self startCoverAudioRecording:row];
        
        self.recordingStatusLabel.text = @"NOW RECORDING";
    }
}

- (void)showLyricsButtonIsPressed:(UIButton*)sender
{
    int row = [self getTableViewRow:sender];
    id audioForRow = [tracksForView objectAtIndex:row];
    
    if ([audioForRow isKindOfClass:[CoverSceneAudio class]]) {
        return;
    }
    
    Audio *audio = (Audio*)audioForRow;
    
    if ([audio.replaceable intValue] == 0) {
        return;
    }
    
    NSString *trimmedLyrics =[[audio lyrics] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedLyrics isEqualToString:@""]) {
        [self loadLyrics:@"no lyrics were found for this track"];
    } else {
        [self loadLyrics:[audio lyrics]];
    }
    
}

- (void)showCueButtonIsPressed:(UIButton *)sender
{
    int row = [self getTableViewRow:sender];
    Cue *theCue = [self.cueController getCurrentCueForTrackIndex:row];
    
    if (self.cueController.currentCue == theCue)
    {
        [self removeAndUnloadCueFromView];
    }
    
    //change the cue only if a different cue is requested
    else if (self.cueController.currentCue != theCue)
    {
        [self removeAndUnloadCueFromView];
        self.cueController.currentCue = theCue;
        
        CGRect frame = CGRectMake(520, 30, 460, 50);
        
        UITextView *textView = [[UITextView alloc] initWithFrame:frame];
        textView.frame = frame;
        textView.text = theCue.content;
        
        self.cueView = textView;
        [textView release];
        
        [self.view addSubview:self.cueView];
        [self.view sendSubviewToBack:self.cueView];
        
        //animate the lyrics view sliding down
        CGRect lyricsFrame = self.lyricsScrollView.frame;
        lyricsFrame.origin.y = lyricsFrame.origin.y + 50;
        lyricsFrame.size.height = lyricsFrame.size.height - 50;
        
        CGRect lyricsLabelFrame = self.lyricsLabel.frame;
        lyricsLabelFrame.origin.y = lyricsLabelFrame.origin.y + 50;
        lyricsLabelFrame.size.height = lyricsLabelFrame.size.height - 50;
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.lyricsScrollView.frame = lyricsFrame;
                             self.lyricsLabel.frame = lyricsLabelFrame;
                         }
                         completion:^(BOOL finished) {
                             NSLog(@"animation done!");
                         }];

    }
}

- (void)removeAndUnloadCueFromView
{
    if (self.cueView && self.cueController.currentCue)
    {
        //animate the lyrics view sliding up
        CGRect lyricsFrame = self.lyricsScrollView.frame;
        lyricsFrame.origin.y = lyricsFrame.origin.y - 50;
        lyricsFrame.size.height = lyricsFrame.size.height + 50;
        
        CGRect lyricsLabelFrame = self.lyricsLabel.frame;
        lyricsLabelFrame.origin.y = lyricsLabelFrame.origin.y - 50;
        lyricsLabelFrame.size.height = lyricsLabelFrame.size.height + 50;
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.lyricsScrollView.frame = lyricsFrame;
                             self.lyricsLabel.frame = lyricsLabelFrame;
                         }
                         completion:^(BOOL finished) {
                             [self.cueView removeFromSuperview];
                             self.cueController.currentCue = nil;
                             self.cueView = nil;
                         }];
    }
}

#pragma mark - instance methods for player

- (void)playPauseButtonIsPressed
{
    if ([self isPlaying] == YES && [self isRecording] == NO) { //if the player is playing
        //is playing
        
        [self stopPlayerWhenPlaying:NO];
        
    } else if ([self isPlaying] == NO && [self isRecording] == YES) { //if the player is recording
    
        //is recording
        if (!stopButtonPressWhenRecordingWarningHasDisplayed) {
            UIAlertView *stopWhenRecordingAlertView = [[[UIAlertView alloc] initWithTitle:@"Stop?" message:@"Do you realy want to stop? :(" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
            stopWhenRecordingAlertView.tag = 1;
            [stopWhenRecordingAlertView show];

            return;
        }
        
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
               
        [self.thePlayer seekTo:0];
        [self.thePlayer stop];
        [self.playPauseButton setImage:playButtonImage forState:UIControlStateNormal];
        stopButtonPressWhenRecordingWarningHasDisplayed = NO;   //reset
        
        [self updatePlayerStatus:NO AndRecordingStatus:NO];
        
        currentRecordingIndex = -1;
        
        if (!thePlayer.stoppedBecauseReachedEnd) {
            //if file exists delete the file first
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtURL:currentRecordingURL error:nil];
        }
        
        //clear values
        currentRecordingAudio = nil;
        currentRecordingURL = nil;
        
        self.recordingStatusLabel.text = @"";
    }
    else //player is neither playing or recording
    {
        //if the play pause button is press, we only expect it to be playing
        [self startPlayerPlaying];
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
    
    [self registerNotifications];
}

- (void)startPlayerPlaying
{
    [self updatePlayerStatus:YES AndRecordingStatus:NO];
    [self.thePlayer play];
    [self.playPauseButton setImage:pauseButtonImage forState:UIControlStateNormal];
}

- (void)stopPlayerWhenPlaying:(bool)hasReachedEnd
{
    [self updatePlayerStatus:NO AndRecordingStatus:NO];
    
    if (self.thePlayer.isPlaying == YES) {
        [self.thePlayer stop];
    }
    
    [self.playPauseButton setImage:playButtonImage forState:UIControlStateNormal];
    
    if (hasReachedEnd == YES) {
        [delegate bringSliderToZero];
    }
    
    self.recordingStatusLabel.text = @"";
}

#pragma mark - instance methods

- (void)startCoverAudioRecording:(int)indexInConsolidatedAudioTracksArray
{
    //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:indexInConsolidatedAudioTracksArray];
    
    [self updatePlayerStatus:NO AndRecordingStatus:YES];
    
    [trackTableView reloadData];
    
    /* start recording once we determine it is a original track */
    
    //added self. to ensure it is being memory managed by the synthesized accessors
    self.currentRecordingAudio = (Audio*)audioForRow;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *userDocumentDirectory = [ShowDAO userDocumentDirectory];
    NSString *uniqueFilename = [MiniMusicalStarUtilities getUniqueFilenameWithoutExt];
    
    NSString *audioCoverFilepath = [userDocumentDirectory stringByAppendingFormat:@"/%@.caf", uniqueFilename];
    
    NSURL *fileURL = [NSURL fileURLWithPath:audioCoverFilepath];
    [fileManager removeItemAtURL:fileURL error:nil];    //if file exists delete the file first
    
    self.currentRecordingURL = fileURL;
    
    [thePlayer stop];
    [thePlayer seekTo:0];
    [thePlayer stop];
    
    //start recording using MixPlayerRecorder
    [thePlayer enableRecordingToFile:fileURL];
    [thePlayer play];
}

- (void)trashCoverAudio:(int)indexInConsolidatedAudioTracksArray
{
    id audioForRow = [tracksForView objectAtIndex:indexInConsolidatedAudioTracksArray];
    
    if ([audioForRow isKindOfClass:[Audio class]]) {
        NSLog(@"Trying to delete an audio track, crazy.");
        return;
    }
    
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Deleting track..."];
    
    CoverSceneAudio *audioToBeRemoved = (CoverSceneAudio*)audioForRow;
    NSURL *urlOfAudioToBeRemoved = [NSURL fileURLWithPath:audioToBeRemoved.path];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if (![fileManager removeItemAtURL:urlOfAudioToBeRemoved error:&error]) {
        NSLog(@"I tried to delete the audio file but failed: %@", error);
    }
    
    [self.theCoverScene removeAudioObject:audioToBeRemoved];
    
    [DSBezelActivityView removeViewAnimated:YES];
    
    [self consolidateArrays];
    [trackTableView reloadData];
}

- (void)recordingIsCompleted
{    
    [self updatePlayerStatus:NO AndRecordingStatus:NO];
      
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

- (bool)isPlaying
{
    return isPlaying;
}

- (void)registerNotifications
{ 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingIsCompleted) name:kMixPlayerRecorderRecordingHasReachedEnd object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPlayerPlayedHasReachedNotification) name:kMixPlayerRecorderPlayingHasReachedEnd object:nil];

}

- (void)receivedPlayerPlayedHasReachedNotification
{
    [self stopPlayerWhenPlaying:YES];
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

- (void) updatePlayerStatus:(bool)playingStatus AndRecordingStatus:(bool)recordingStatus
{
    isPlaying = playingStatus;
    isRecording = recordingStatus;
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
    
    lyricsLabel.frame = CGRectMake(-15, 70, lyricsLabel.frame.size.width-100, lyricsLabelFrame.size.height); //set the new size of the label, we are only changing the height
    
    [lyricsScrollView setContentSize:CGSizeMake(lyricsLabel.frame.size.width, lyricsLabelFrame.size.height+100)]; //set content size of scroll view using calculated size of the text on the label
    
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
    lyricsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, LYRICS_VIEW_WIDTH+50, LYRICS_VIEW_HEIGHT)];
    
    //configure the lyrics label
    lyricsLabel.lineBreakMode = UILineBreakModeWordWrap; //line break, word wrap
	lyricsLabel.numberOfLines = 0; //0 - dynamic ngit umber of lines
    [lyricsLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:16]];
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

- (IBAction) playTutorial:(id)sender
{
    //play tutorial video player
    [delegate playMovie:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio" ofType:@"m4v"]]];
}


@end

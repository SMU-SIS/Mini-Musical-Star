//
//  TracksTableViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 15/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TracksTableViewController.h"
#import "Audio.h"
#import "CoverSceneAudio.h"
#import "TrackTableViewCell.h"
#import "DSActivityView.h"
#import "MiniMusicalStarUtilities.h"
#import "ShowDAO.h"
#import "AudioEditorViewController.h"

@implementation TracksTableViewController

@synthesize lyricsViewControllerDelegate;
@synthesize audioEditorViewControllerDelegate;

@synthesize thePlayer;
@synthesize theScene;
@synthesize theCoverScene;
@synthesize context;
@synthesize playPauseButton;

@synthesize tracksForView;
@synthesize tracksForViewNSURL;
@synthesize arrayOfReplaceableAudios;

@synthesize currentRecordingURL;
@synthesize currentRecordingAudio;

#pragma initializers and deinitalizers

- (id)initWithScene:(Scene*)aScene andACoverScene:(CoverScene*)aCoverScene andAContext:(NSManagedObjectContext*)aContext
{
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.theScene = aScene;
        self.theCoverScene = aCoverScene;
        self.context = aContext;
        
        [self updatePlayerStatus:NO AndRecordingStatus:NO];
        currentRecordingIndex = -1;
        
        self.tracksForView = [[NSMutableArray alloc] initWithCapacity:1];
        self.tracksForViewNSURL = [[NSMutableArray alloc] initWithCapacity:1];
        
        [self performSelector:@selector(consolidateArrays)];
        [self consolidateReplaceableAudios];
        
        //KVO the Audio NSSet
        [self.theCoverScene addObserver:self forKeyPath:@"Audio" options:0 context:@"NewCoverTrackAdded"];

        self.tableView.backgroundColor = [UIColor clearColor];

        //load first replaceable audio's lyrics
        if (arrayOfReplaceableAudios != nil && [arrayOfReplaceableAudios count] != 0) {
            Audio *anAudio = (Audio*) [arrayOfReplaceableAudios objectAtIndex:0];
            [lyricsViewControllerDelegate loadLyrics:anAudio.lyrics];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autosaveWhenContextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
        
        self.tableView.separatorColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    [self.theCoverScene removeObserver:self forKeyPath:@"Audio"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.thePlayer stop];
    
    [thePlayer release];
    [theScene release];
    [theCoverScene release];
    [context release];
    [playPauseButton release];
    
    [tracksForView release];
    [tracksForViewNSURL release];
    [arrayOfReplaceableAudios release];
    
    [currentRecordingURL release];
    [currentRecordingAudio release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.theScene.audioTracks.count + self.theCoverScene.Audio.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell"];
    UILabel *trackNameLabel;
    UIButton *recordOrTrashButton;
    UIButton *muteOrUnmuteButton;
    UIButton *showLyricsButton;
    UIButton *showCueButton;
    UILabel *muteUnmuteLabel;
    UILabel *recordRecordingLabel;
    UILabel *showHideLyricsLabel;
    UILabel *showCuesLabel;
    
    //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:[indexPath row]];
    
    if (cell == nil) {
        TrackTableViewCell *aCell = [[TrackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TrackCell"];
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TrackTableViewCell" owner:aCell options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        //int xShift = 30;
        
        [aCell.recordOrTrashButton addTarget:self action:@selector(recordOrTrashButtonIsPressed:) forControlEvents:UIControlEventTouchDown];
        [aCell.muteOrUnmuteButton addTarget:self action:@selector(muteOrUnmuteButtonIsPressed:) forControlEvents:UIControlEventTouchDown];
        [aCell.showLyricsButton addTarget:self action:@selector(showLyricsButtonIsPressed:) forControlEvents:UIControlEventTouchDown];
        [aCell.showCueButton addTarget:self action:@selector(showCueButtonIsPressed:)forControlEvents:UIControlEventTouchDown];
        
        [aCell release];
    }
    
    trackNameLabel = (UILabel*)[cell.contentView viewWithTag:1];
    trackNameLabel.text = [audioForRow valueForKey:@"title"]; //set the name of the track
    
    muteOrUnmuteButton = (UIButton*)[cell.contentView viewWithTag:2];
    recordOrTrashButton = (UIButton*)[cell.contentView viewWithTag:3];
    showLyricsButton = (UIButton*)[cell.contentView viewWithTag:4];
    showCueButton = (UIButton*)[cell.contentView viewWithTag:5];
    muteUnmuteLabel = (UILabel*)[cell.contentView viewWithTag:6];
    recordRecordingLabel = (UILabel*)[cell.contentView viewWithTag:7];
    showHideLyricsLabel = (UILabel*)[cell.contentView viewWithTag:8];
    showCuesLabel = (UILabel*)[cell.contentView viewWithTag:9];
    
    if ([audioForRow isKindOfClass:[Audio class]]) {
        if ([(NSNumber *)[audioForRow valueForKey:@"replaceable"] boolValue]) {
            
            if ([self isRecording] && [indexPath row] == currentRecordingIndex) {
                [recordOrTrashButton setImage:[UIImage imageNamed:@"recording.png"] forState:UIControlStateNormal];
                recordRecordingLabel.text = @"Recording";
            } else {
                [recordOrTrashButton setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
                recordRecordingLabel.text = @"Record";
            }
            
            [showLyricsButton setImage:[UIImage imageNamed:@"lyrics_button.png"] forState:UIControlStateNormal];
            showHideLyricsLabel.text = @"Show lyrics";
            
            [showCueButton setImage:[UIImage imageNamed:@"audiocues.png"] forState:UIControlStateNormal];
            
        } else {
            [recordOrTrashButton setImage:nil forState:UIControlStateNormal];
            recordRecordingLabel.text = @"";
            [showLyricsButton setImage:nil forState:UIControlStateNormal];
            showHideLyricsLabel.text = @"";
        }
        
        if (![thePlayer busNumberIsMuted:[indexPath row]]) {
            [muteOrUnmuteButton setImage:[UIImage imageNamed:@"unmuted.png"] forState:UIControlStateNormal];
            muteUnmuteLabel.text = @"Mute";
            
        } else {
            [muteOrUnmuteButton setImage:[UIImage imageNamed:@"muted.png"] forState:UIControlStateNormal];
            muteUnmuteLabel.text = @"Unmute";
        }
        
    } else { //if CoverAudio        
        [recordOrTrashButton setImage:[UIImage imageNamed:@"trashbin.png"] forState:UIControlStateNormal];
        recordRecordingLabel.text = @"Delete track";
        
        if (![thePlayer busNumberIsMuted:[indexPath row]]) {
            [muteOrUnmuteButton setImage:[UIImage imageNamed:@"unmuted.png"] forState:UIControlStateNormal];
            muteUnmuteLabel.text = @"Mute";
        } else {
            [muteOrUnmuteButton setImage:[UIImage imageNamed:@"muted.png"] forState:UIControlStateNormal];
            muteUnmuteLabel.text = @"Unmute";
        }
        
        [showCueButton setImage:nil forState:UIControlStateNormal];
        showCuesLabel.text = @"";

        showHideLyricsLabel.text = @"";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - instance methods

- (void)updatePlayerStatus:(bool)playingStatus AndRecordingStatus:(bool)recordingStatus
{
    isPlaying = playingStatus;
    isRecording = recordingStatus;
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

- (bool)isRecording
{
    return isRecording;
}

- (bool)isPlaying
{
    return isPlaying;
}

- (void)recordingIsCompleted
{    
    [self updatePlayerStatus:NO AndRecordingStatus:NO];
    
    CoverSceneAudio *newCoverSceneAudio = [NSEntityDescription insertNewObjectForEntityForName:@"CoverSceneAudio" inManagedObjectContext:context];
    newCoverSceneAudio.title = currentRecordingAudio.title;
    newCoverSceneAudio.path = [currentRecordingURL path];
    newCoverSceneAudio.OriginalHash = currentRecordingAudio.hash;
    [self.theCoverScene addAudioObject:newCoverSceneAudio];
    
    [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    
    currentRecordingAudio = nil;
    currentRecordingURL = nil;
    currentRecordingIndex = -1;

    [self.audioEditorViewControllerDelegate updateRecordingStatusLabel:@""];
    
    [self.tableView reloadData];
}

- (int)getTableViewRow:(UIButton*)sender
{
    UITableViewCell *trackCell = (UITableViewCell*)sender.superview.superview;
    UITableView *tableView = (UITableView*)[trackCell superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:trackCell];
    return indexPath.row;
}

#pragma mark - instance methods for player

- (void)playPauseButtonIsPressed
{
    if ([self isPlaying] == YES && [self isRecording] == NO) { //if the player is playing
        //is playing
        
        [self stopPlayerWhenPlaying:NO];
        
    } else if ([self isPlaying] == NO && [self isRecording] == YES) { //if the player is recording
        
        [self.thePlayer seekTo:0];
        [self.thePlayer stop];
        [self recordingIsCompleted];
               
    }
    else //player is neither playing or recording
    {
        //if the play pause button is press, we only expect it to be playing
        [self startPlayerPlaying];
    }
    
    [self.tableView reloadData];
}

- (void)startPlayerPlaying
{
    [self updatePlayerStatus:YES AndRecordingStatus:NO];
    [self.thePlayer play];
    [self.playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
}

- (void)stopPlayerWhenPlaying:(bool)hasReachedEnd
{
    [self updatePlayerStatus:NO AndRecordingStatus:NO];
    
    if (self.thePlayer.isPlaying == YES) {
        [self.thePlayer stop];
    }
    
    [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    
    if (hasReachedEnd == YES) {
        //[delegate bringSliderToZero];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBringSliderToZero object:self];
    }
    
    [self.audioEditorViewControllerDelegate updateRecordingStatusLabel:@""];
}

#pragma mark - instance methods for audio and coveraudio arrays

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
    [self.tableView reloadData];
}

- (void)startCoverAudioRecording:(int)indexInConsolidatedAudioTracksArray
{
    //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:indexInConsolidatedAudioTracksArray];
    
    [self updatePlayerStatus:NO AndRecordingStatus:YES];
    
    [self.tableView reloadData];
    
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

#pragma mark - NSNotification methods
- (void)registerNotifications
{ 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingIsCompleted) name:kMixPlayerRecorderRecordingHasReachedEnd object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPlayerPlayedHasReachedNotification) name:kMixPlayerRecorderPlayingHasReachedEnd object:nil];
}

- (void)deRegisterFromNSNotifcationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receivedPlayerPlayedHasReachedNotification
{
    [self stopPlayerWhenPlaying:YES];
}

#pragma mark - autosave methods

-(void)autosaveWhenContextDidChange:(NSNotification*)notification
{
    NSError *thisError;
    [context save:&thisError];
}

#pragma mark - 

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
        
        [self.playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
        //if the audiotrack can be replaced, start recording
        [self startCoverAudioRecording:row];
        
        [self.audioEditorViewControllerDelegate updateRecordingStatusLabel:@"NOW RECORDING"];
    }
}

- (void)muteOrUnmuteButtonIsPressed:(UIButton *)sender
{    
    int busNumber = [self getTableViewRow:sender];
    
    if ([thePlayer busNumberIsMuted:busNumber]) {
        [thePlayer unmuteBusNumber:busNumber]; 
    } else {
        [thePlayer muteBusNumber:busNumber];
    }
    
    [self.tableView reloadData];
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
        [lyricsViewControllerDelegate loadLyrics:@"no lyrics were found for this track"];
    } else {
        [lyricsViewControllerDelegate loadLyrics:[audio lyrics]];
    }
    
}

#pragma mark - KVO callbacks

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)changeContext
{    
    NSString *kvoContext = (NSString *)changeContext;
    if ([kvoContext isEqualToString:@"NewCoverTrackAdded"]) {
        [self performSelector:@selector(consolidateArrays)];
        [self.tableView reloadData];
    }
}

#pragma mark - instance methods for cues
- (void)setCueButton:(BOOL)shouldShow forTrackIndex:(NSUInteger)trackIndex
{
    //get the table row corresponding to the current track
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:trackIndex inSection:0];
    UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIButton *showCueButton = (UIButton *)[theCell.contentView viewWithTag:5];
    UILabel *showCuesLabel = (UILabel*)[theCell.contentView viewWithTag:9];
    
    [showCueButton setHidden:!shouldShow];
    [showCuesLabel setHidden:!shouldShow];
}

- (void)showCueButtonIsPressed:(UIButton*)sender
{
    [audioEditorViewControllerDelegate cueButtonIsPressed:[self getTableViewRow:sender]];
}

@end

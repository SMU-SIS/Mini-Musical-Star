//
//  AudioEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "AudioEditorViewController.h"
#import "Audio.h"
#import "CoversFilenameGenerator.h"

#import "ShowDAO.h"

@implementation AudioEditorViewController
@synthesize thePlayer, theAudioObjects, theCoverScene, context;
@synthesize tracksForView;
@synthesize trackTableView, recordImage, recordingImage, mutedImage, unmutedImage, trashbinImage;
@synthesize lyricsScrollView, lyricsLabel;
@synthesize lyrics;
@synthesize currentRecordingURL, currentRecordingAudio;
@synthesize playPauseButton;

- (void)dealloc
{
    [thePlayer stop];
    [thePlayer release];
    [theAudioObjects release];
    [theCoverScene release];
    [context release];
    
    [tracksForView release];
    [trackTableView release];
    [recordImage release];
    [recordingImage release];
    [mutedImage release];
    [trashbinImage release];
    
    [currentRecordingAudio release];
    [currentRecordingURL release];
    
    [lyricsScrollView release];
    [lyricsLabel release];
    
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
        self.theAudioObjects = [aScene audioTracks];
        self.theCoverScene = aCoverScene;
        self.context = aContext;
        self.playPauseButton = aPlayPauseButton;
        
        isPlaying = NO;
        isRecording = NO;
        
        //init the player with the audio tracks
        thePlayer = [[MixPlayerRecorder alloc] initWithAudioFileURLs:[aScene arrayOfAudioTrackURLs]];
        
        [self performSelector:@selector(consolidateOriginalAndCoverTracks)];
        
        Audio *firstAudio = (Audio*)[tracksForView objectAtIndex:0];
        lyrics = firstAudio.lyrics;
        
        [self drawLyricsView];
    }
    
    return self;
}

- (void)consolidateOriginalAndCoverTracks
{  
    self.tracksForView = [NSMutableArray arrayWithCapacity:theAudioObjects.count + theCoverScene.Audio.count];
    
    [theAudioObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.tracksForView addObject:obj];
    }];
    
    [theCoverScene.Audio enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.tracksForView addObject:obj];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //KVO the Audio NSSet
    [self.theCoverScene addObserver:self forKeyPath:@"Audio" options:0 context:@"NewCoverTrackAdded"];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // If you initialize the table view with the UIView method initWithFrame:,
    //the UITableViewStylePlain style is used as a default.
    trackTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 500, 300) style:UITableViewStylePlain];
    
    trackTableView.delegate = self;
	trackTableView.dataSource = self;
    
    trackTableView.bounces = NO;
    trackTableView.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:trackTableView];
    
    trackTableView.separatorColor = [UIColor whiteColor];
    
    //load images
    recordImage = [UIImage imageNamed:@"record.png"];
    recordingImage = [UIImage imageNamed:@"recording.png"];
    mutedImage = [UIImage imageNamed:@"muted.png"];
    unmutedImage = [UIImage imageNamed:@"unmuted.png"];
    trashbinImage = [UIImage imageNamed:@"trashbin.png"];
    
    //set default value
    currentRecordingTrack = -1; //representing no track is being recorded
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.theCoverScene removeObserver:self forKeyPath:@"Audio"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - UITableView delegate methods

// We will only have 1 section, so don't change the value here.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return theAudioObjects.count + theCoverScene.Audio.count;
}

#define TRACK_CELL_WIDTH 500
#define TRACK_CELL_HEIGHT 100
#define TRACK_CELL_RIGHT 350    //500-150

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *trackNameLabel;
    UIButton *recordOrTrashButton;
    UIView *trackCellRightPanel;
    UIView *trackCellRightIndicator;
    UIButton *rightPanelButton;
    
    //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:[indexPath row]];
    
    if (cell == nil)
    {
        //create all the new objects
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        
        cell.contentView.backgroundColor = [UIColor blackColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        /* label which displays the track name */
        trackNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 120, 30)];
        trackNameLabel.backgroundColor = [UIColor blackColor];
        trackNameLabel.textAlignment =  UITextAlignmentCenter;
        [trackNameLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:18]];
        [cell.contentView addSubview:trackNameLabel]; //add label to view
        trackNameLabel.tag = 1; //tag the object to an integer value
        [trackNameLabel release];
        
        /* button for the user to record a cover track */
        //create an empty place holder for the record button
        recordOrTrashButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 50, 50, 50)];
        [cell.contentView addSubview:recordOrTrashButton];
        recordOrTrashButton.tag = 2;
        [recordOrTrashButton release];
        
        /* the right panel indicator */
        trackCellRightIndicator = [[UIView alloc] initWithFrame:CGRectMake(150, 0, TRACK_CELL_RIGHT, TRACK_CELL_HEIGHT)];
        [cell.contentView addSubview:trackCellRightIndicator];
        trackCellRightIndicator.tag = 3;
        [trackCellRightIndicator setBackgroundColor:[UIColor purpleColor]];
        
        /* draw the gradient-ed background of white to black */
        [trackCellRightIndicator.layer insertSublayer:[self createGradientLayer:trackCellRightIndicator.bounds firstColor:[UIColor blackColor] andSecondColor:[UIColor whiteColor]] atIndex:0];
        
        [trackCellRightIndicator release];
        
        /* the right panel of the row */
        trackCellRightPanel = [[UIView alloc] initWithFrame:CGRectMake(150, 0, TRACK_CELL_RIGHT, TRACK_CELL_HEIGHT)];
        trackCellRightPanel.alpha = 0.8;
        trackCellRightPanel.tag = 4;
        [cell.contentView addSubview:trackCellRightPanel]; //add label to view
                
        //crgit eate the mute/unmute button for the track
        rightPanelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TRACK_CELL_RIGHT, TRACK_CELL_HEIGHT)];
        rightPanelButton.tag = 5;
        [rightPanelButton setImage:unmutedImage forState:UIControlStateNormal];
        rightPanelButton.titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:30];
        rightPanelButton.titleLabel.alpha = 0.5;
        rightPanelButton.alpha = 0.8;
        
        [rightPanelButton addTarget:self action:@selector(muteToggleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [trackCellRightPanel addSubview:rightPanelButton];
        [trackCellRightPanel bringSubviewToFront:rightPanelButton];
        
        [rightPanelButton release];
        [trackCellRightPanel release];
    }
    
    // Here, you just configure the objects as appropriate for the row
    trackNameLabel = (UILabel*)[cell.contentView viewWithTag:1];
    trackNameLabel.text = [audioForRow valueForKey:@"title"]; //set the name of the track
    
    //determine the color of the font by checking if the track is a original or audio
    if ([audioForRow isKindOfClass:[Audio class]])
    {
        trackNameLabel.textColor = [UIColor whiteColor];
    }
    else if ([audioForRow isKindOfClass:[CoverSceneAudio class]])
    {
        trackNameLabel.textColor = [UIColor redColor];
    }
    
    recordOrTrashButton = (UIButton*)[cell.contentView viewWithTag:2];
    
    //determines what button image should we load in the image placeholder for each row/track
    if ([audioForRow isKindOfClass:[Audio class]] && [(NSNumber *)[audioForRow valueForKey:@"replaceable"] boolValue])
    {
        if (indexPath.row == currentRecordingTrack)
        {
            //if it is a replaceable Audio and a cover is being recorded
            [recordOrTrashButton setImage:recordingImage forState:UIControlStateNormal];
        }
        else
        {
            //if it is a replaceable and a cover is not being recorded
            [recordOrTrashButton setImage:recordImage forState:UIControlStateNormal];
        }
    } else if ([audioForRow isKindOfClass:[CoverSceneAudio class]])
    {
        //if it is a CoverSceneAudio and it can be trashed!
        [recordOrTrashButton setImage:trashbinImage forState:UIControlStateNormal];
    }
    
    //previously UIControlEventTouchUpInside, now 
    [recordOrTrashButton addTarget:self action:@selector(recordOrTrashButtonIsPressed:) forControlEvents:UIControlEventTouchDown];
    
    trackCellRightPanel = (UIView*)[cell.contentView viewWithTag:4];
    
    trackCellRightIndicator = (UIView*)[cell.contentView viewWithTag:3];
    CALayer *layer = trackCellRightIndicator.layer;
    layer.sublayers = nil; //remove all the sublayers inside the layer. if not we will keep adding additional layers.
    
    if (indexPath.row == currentRecordingTrack && isRecording == YES)
    {
        /* draw the gradient-ed background of red to black */            
        [trackCellRightIndicator.layer insertSublayer:[self createGradientLayer:trackCellRightIndicator.bounds firstColor:[UIColor redColor] andSecondColor:[UIColor whiteColor]] atIndex:0];
    }
    else if (isRecording == NO && isPlaying == YES)
    {      
        if ([thePlayer busNumberIsMuted:indexPath.row])
        {
            [trackCellRightIndicator.layer insertSublayer:[self createGradientLayer:trackCellRightIndicator.bounds firstColor:[UIColor blackColor] andSecondColor:[UIColor whiteColor]] atIndex:0];
        }
        else
        {           
            [trackCellRightIndicator.layer insertSublayer:[self createGradientLayer:trackCellRightIndicator.bounds firstColor:[UIColor colorWithRed:34/255.0 green:139/255.0 blue:34/255.0 alpha:1] andSecondColor:[UIColor whiteColor]] atIndex:0];
        }
    }
    else
    {            
        /* draw the gradient-ed background of white to black */         
        [trackCellRightIndicator.layer insertSublayer:[self createGradientLayer:trackCellRightIndicator.bounds firstColor:[UIColor blackColor] andSecondColor:[UIColor whiteColor]] atIndex:0];
    }    
    
    return cell;
}


//This method is for you to set the height of the table view.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRACK_CELL_HEIGHT;
}

#pragma mark - audio manipulation and recording methods

#pragma mark - KVO callbacks
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)changeContext
{
    //NSLog(@"Inside observeValueForKeyPath");
    
    NSString *kvoContext = (NSString *)changeContext;
    if ([kvoContext isEqualToString:@"NewCoverTrackAdded"])
    {
        //refresh the table
        [self performSelector:@selector(consolidateOriginalAndCoverTracks)];
        [trackTableView reloadData];
    }
}

#pragma mark - IBAction events
- (void)muteToggleButtonTapped:(UIButton *)sender
{    
    //check which row's rightPanelButton was clicked
    UIButton *rightPanelButton = (UIButton*)sender;
    UITableViewCell *trackCell = (UITableViewCell*) rightPanelButton.superview.superview.superview;
    UITableView *tableView = (UITableView*)[trackCell superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:trackCell];
    
    int busNumber = indexPath.row;
    
    if ([thePlayer busNumberIsMuted:busNumber])
    {
        [thePlayer unmuteBusNumber:busNumber]; 
        [rightPanelButton setImage:unmutedImage forState:UIControlStateNormal];
    }
    else
    {
        [thePlayer muteBusNumber:busNumber];
        [rightPanelButton setImage:mutedImage forState:UIControlStateNormal];
    }
    
    [trackTableView reloadData];    //refresh the table view
}

-(void)recordOrTrashButtonIsPressed:(UIButton *)sender
{
    //refractor this method
        //if this button is pressed for trashing, call trashCoverAudio
        //if this button is pressed for recording, write another method startCoverAudioRecording
    
    int row = -1;
    
    if (isRecording == YES)
    {        
        UIAlertView *recordButtonHitWhenRecordingAlert = [[UIAlertView alloc] initWithTitle:@"Opps!" message:@"You are not supposed to hit me when recording!" delegate:nil cancelButtonTitle:@"I'm sorry!" otherButtonTitles:nil];
        [recordButtonHitWhenRecordingAlert show];
        [recordButtonHitWhenRecordingAlert release];
        
        return;
    }
    
    //checks which track the user is trying to record by checking which row the button came from
    UIButton *recordButton = (UIButton *)sender;
    UIView *cellContentView = (UIView*)recordButton.superview;
    UITableViewCell *trackCell = (UITableViewCell*)[cellContentView superview];
    UITableView *tableView = (UITableView*)[trackCell superview];
    NSIndexPath *indexPath = [tableView indexPathForCell:trackCell];
    row = indexPath.row;
    
    //get the corresponding Audio object
    id audioForRow = [tracksForView objectAtIndex:row];
    
    //if this is a recorded track or a replaceable track, exit this method
    if ([audioForRow isKindOfClass:[CoverSceneAudio class]])
    {
        return;
    }
    else if ([audioForRow isKindOfClass:[Audio class]])
    {
        //check if it is a replaceable audio
        
        Audio *audio = (Audio*)audioForRow;
        NSNumber *isAudioReplaceable = audio.replaceable;
        
        if ([isAudioReplaceable intValue] == 0)
        {
            //if the audio track is cannot be replaced
            return;
        }
    }
    
    currentRecordingTrack = row;
    isRecording = YES;
    
    //reload the tableviewcell
    [trackTableView reloadData];
    
    /* start recording once we determine it is a original track */
    currentRecordingAudio = (Audio*)audioForRow;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *userDocumentDirectory = [ShowDAO getUserDocumentDir];
    NSString *uniqueFilename = [AudioEditorViewController getUniqueFilenameWithoutExt];
    
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

#pragma mark - instance methods
- (void)coverAudioRecording
{
    
}

- (void)trashCoverAudio
{
    //remove the CoverSceneAudio file
    
    //delete the file from the user directory
        //check if the file exist before deleting to prevent error
}

- (CAGradientLayer*)createGradientLayer:(CGRect)frame firstColor:(UIColor*)firstColor andSecondColor:(UIColor*)secondColor {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    gradientLayer.frame = frame;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[secondColor CGColor], nil];            
    
    return gradientLayer;
}

- (void)resetRecordingValues
{
    currentRecordingAudio = nil;
    currentRecordingURL = nil;
}

- (void)recordingIsCompleted
{
    currentRecordingTrack = -1;
    isRecording = NO;
      
    CoverSceneAudio *newCoverSceneAudio = [NSEntityDescription insertNewObjectForEntityForName:@"CoverSceneAudio" inManagedObjectContext:context];

    newCoverSceneAudio.title = currentRecordingAudio.title;
    newCoverSceneAudio.path = [currentRecordingURL path];
    newCoverSceneAudio.OriginalHash = currentRecordingAudio.hash;
    
    [self.theCoverScene addAudioObject:newCoverSceneAudio]; //receing EXC_BAD_ACCESS here when exit and record
    
    //init the player with the original audio tracks and cover tracks
    NSMutableArray *tracksForViewNSURL = [NSMutableArray arrayWithCapacity:[tracksForView count]-1];
    
    //populate the NSURLs of each audios into an array
    [tracksForView enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Audio *anAudio = (Audio*)obj;
        NSString *path = anAudio.path;
        [tracksForViewNSURL addObject:[NSURL fileURLWithPath:path]];
    }];
    
    [thePlayer release];
    
    //reinit the player
    thePlayer = [[MixPlayerRecorder alloc] initWithAudioFileURLs:tracksForViewNSURL];
    
    [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    
    [self resetRecordingValues];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //bring the seeker of player back to the starting point
    [thePlayer seekTo:0]; //seekTo:0 is causing the NSNotification to call this method
    [thePlayer stop];
    
    [trackTableView reloadData];
}

- (void)playButtonIsPressed
{
    if (isRecording) 
    {
        //nothing should be done here.
    }
    else if (!isPlaying)
    {
        isPlaying = YES;
        [trackTableView reloadData];
    }
}

- (void)stopButtonIsPresssed
{
    if (isRecording) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        currentRecordingTrack = -1;
        isRecording = NO;
        
        [trackTableView reloadData];
        
        if (!thePlayer.stoppedBecauseReachedEnd)
        {
            //if file exists delete the file first
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtURL:currentRecordingURL error:nil];
        }
        
        //bring the seeker of player back to the starting point
        [thePlayer seekTo:0];
        [thePlayer stop];
        
        //clear values
        [self resetRecordingValues];
    }
    else if (isPlaying)
    {
        isPlaying = NO;
        [trackTableView reloadData];
        
    }
}

- (bool)isRecording
{
    return isRecording;
}

//This is for scene edit view to pass me a pointer to the play pause button
- (void)giveMePlayPauseButton:(UIButton*)aButton
{
    self.playPauseButton = aButton;
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingIsCompleted) name:kMixPlayerRecorderPlaybackStopped object:nil];
}

/* constants related to displaying lyrics */
#define LYRICS_VIEW_WIDTH 1024-500 //the entire width of the landscape screen
#define LYRICS_VIEW_HEIGHT 580
#define LYRICS_VIEW_X 500
#define LYRICS_VIEW_Y 0

- (void) drawLyricsView
{
    [self createLyricsScrollView];
    [self createLyricsLabel];
    
    CGRect lyricsLabelFrame = lyricsLabel.bounds; //get the CGRect representing the bounds of the UILabel
    
    lyricsLabelFrame.size = [lyrics sizeWithFont:lyricsLabel.font constrainedToSize:CGSizeMake(LYRICS_VIEW_WIDTH-20, 100000) lineBreakMode:lyricsLabel.lineBreakMode]; //get a CGRect for dynamically resizing the label based on the text. cool.
    
    lyricsLabel.frame = CGRectMake(0, 0, lyricsLabel.frame.size.width-10, lyricsLabelFrame.size.height); //set the new size of the label, we are only changing the height
    
    [lyricsScrollView setContentSize:CGSizeMake(lyricsLabel.frame.size.width, lyricsLabelFrame.size.height)]; //set content size of scroll view using calculated size of the text on the label
    
    lyricsLabel.text = lyrics;
    
    [lyricsScrollView addSubview:lyricsLabel];
    [self.view addSubview:lyricsScrollView];
}

- (UIScrollView*)createLyricsScrollView {
    lyricsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(LYRICS_VIEW_X, LYRICS_VIEW_Y, LYRICS_VIEW_WIDTH, LYRICS_VIEW_HEIGHT)]; 
    
    //configure the lyrics scroll view
    lyricsScrollView.directionalLockEnabled = YES;
    lyricsScrollView.showsHorizontalScrollIndicator = NO;
    lyricsScrollView.showsVerticalScrollIndicator = YES;
    lyricsScrollView.bounces = NO;
    [lyricsScrollView setBackgroundColor:[UIColor whiteColor]];
    
    return lyricsScrollView;
}

- (UILabel*)createLyricsLabel {
    lyricsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LYRICS_VIEW_WIDTH, LYRICS_VIEW_HEIGHT)];
    
    //configure the lyrics label
    lyricsLabel.lineBreakMode = UILineBreakModeWordWrap; //line break, word wrap
	lyricsLabel.numberOfLines = 0; //0 - dynamic ngit umber of lines
    [lyricsLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:24]];
    lyricsLabel.textColor = [UIColor whiteColor];
    lyricsLabel.textAlignment =  UITextAlignmentCenter;
    lyricsLabel.backgroundColor = [UIColor blackColor];
    
    return lyricsLabel;
}

- (void)deRegisterFromNSNotifcationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
            if ([thePlayer busNumberIsMuted:idx] == NO)
            {
                [mutableArrayOfAudioURLs addObject:audioURL];
                
            }
            
        } else if ([obj isKindOfClass:[CoverSceneAudio class]])
        {
            CoverSceneAudio *anCoverSceneAudio = (CoverSceneAudio*)obj;
            NSURL *audioURL = [NSURL fileURLWithPath:anCoverSceneAudio.path];
            
            //add only if the audio is not muted
            if ([thePlayer busNumberIsMuted:idx] == NO)
            {
                [mutableArrayOfAudioURLs addObject:audioURL];
                
            }
        }
        
    }];
    
    NSArray *arrayOfAudioURLs = [[[NSArray alloc] initWithArray:mutableArrayOfAudioURLs] autorelease];
    
    return arrayOfAudioURLs;
}

#pragma mark - class methods
+ (NSString*)getUniqueFilenameWithoutExt
{
    NSString *timeIntervalInString = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSString *uniqueFilename = [CoversFilenameGenerator returnMD5HashOfString:timeIntervalInString];
    return uniqueFilename;
}

@end

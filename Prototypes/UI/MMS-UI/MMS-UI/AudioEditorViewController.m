//
//  AudioEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "AudioEditorViewController.h"

@implementation AudioEditorViewController
@synthesize thePlayer, theAudioObjects, theCoverScene, context;
@synthesize tracksForView;
@synthesize trackTableView, recordImage, recordingImage;
@synthesize lyricsScrollView, lyricsLabel, lyricsView;
@synthesize lyrics;
@synthesize currentRecordingNSURL, currentRecordingTrackTitle;
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
    
    [currentRecordingNSURL release];
    [currentRecordingTrackTitle release];
    
    [lyricsScrollView release];
    [lyricsLabel release];
    [lyricsView release];
    
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
        self.theAudioObjects = aScene.audioList;
        //self.theScene = aScene;
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
        
        [self prepareLyricsView];
        
        
        UIButton *showAndDismissLyricsButton;
        showAndDismissLyricsButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        showAndDismissLyricsButton.frame = CGRectMake(900, 25, 100, 50);
        [showAndDismissLyricsButton setTitle:@"toggle lyrics" forState:UIControlStateNormal];
        [self.view addSubview:showAndDismissLyricsButton];  
        [showAndDismissLyricsButton addTarget:self action:@selector(showAndDismissLyricsButtonIsPressed) forControlEvents:UIControlEventTouchDown];
        [showAndDismissLyricsButton release];

        
    }
    
    return self;
}

- (void)consolidateOriginalAndCoverTracks
{
//    NSLog(@"Inside consolidateOriginalAndCoverTracks");
    //[tracksForView release];
    
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
    trackTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 1024, 300) style:UITableViewStylePlain];
    
    trackTableView.delegate = self;
	trackTableView.dataSource = self;
    
    trackTableView.bounces = NO;
    trackTableView.backgroundColor = [UIColor cyanColor];
    
    [self.view addSubview:trackTableView];
    
    trackTableView.separatorColor = [UIColor whiteColor];
    
    //load images
    recordImage = [UIImage imageNamed:@"record.png"];
    recordingImage = [UIImage imageNamed:@"recording.png"];
    
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

#pragma mark UITableView delegate methods

// We will only have 1 section, so don't change the value here.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //2 is for the empty row at the bottom
    return theAudioObjects.count + theCoverScene.Audio.count + 2;
}

- (void)muteToggleButtonTapped:(UIButton *)sender
{    
    int busNumber = sender.tag;
    
    if ([thePlayer busNumberIsMuted:busNumber])
    {
        [thePlayer unmuteBusNumber:busNumber];
        [sender setTitle:@"tap to mute" forState:UIControlStateNormal];        
    }
    
    else
    {
        [thePlayer muteBusNumber:busNumber];
        [sender setTitle:@"tap to unmute" forState:UIControlStateNormal];
    }
    
    [trackTableView reloadData];
    
}

// This method is called for each cell in the table view.
// This method is called whenever we are scrolling - try adding a NSLog to see.
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *BlankCellIdentifier = @"BlankCell";
    
    if ([indexPath row] <= (theAudioObjects.count + theCoverScene.Audio.count - 1))
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *trackNameLabel;
        UIButton *recordButton;
        UIView *trackCellRightPanel;
        UIView *trackCellRightIndicator;
        
        //get the corresponding Audio object
        id audioForRow = [tracksForView objectAtIndex:[indexPath row]];
        
        //rows that are supposed to represent tracks
        
        //create the mute/unmute button for the track
        UIButton *rightPanelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024-150, 100)];
        [rightPanelButton setTag:[indexPath row]];
        [rightPanelButton setTitle:@"tap to mute" forState:UIControlStateNormal];
        rightPanelButton.titleLabel.font = [UIFont fontWithName:@"GillSans-Bold" size:30];
        rightPanelButton.titleLabel.alpha = 0.5;
        
        [rightPanelButton addTarget:self action:@selector(muteToggleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
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
            recordButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 50, 50, 50)];
            [cell.contentView addSubview:recordButton];
            recordButton.tag = 2;
            [recordButton release];
            
            
            /* the right panel indicator */
            trackCellRightIndicator = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 1024-150, 100)];
            [cell.contentView addSubview:trackCellRightIndicator];
            trackCellRightIndicator.tag = 3;
            [trackCellRightIndicator setBackgroundColor:[UIColor purpleColor]];
            
            /* draw the gradient-ed background of white to black */
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = trackCellRightIndicator.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
            [trackCellRightIndicator.layer insertSublayer:gradient atIndex:0];
            
            
            [trackCellRightIndicator release];
            
            
            /* the right panel of the row */
            trackCellRightPanel = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 1024-150, 100)];
            trackCellRightPanel.alpha = 0.8;
            
            [trackCellRightPanel addSubview:rightPanelButton];
            
            [cell.contentView addSubview:trackCellRightPanel]; //add label to view
            
            trackCellRightPanel.tag = 4;
            rightPanelButton.alpha = 0.8;
            [trackCellRightPanel bringSubviewToFront:rightPanelButton];
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
        
        recordButton = (UIButton*)[cell.contentView viewWithTag:2];
        
        //add the record button image into the placeholder only if the row represents a original track
        if ([audioForRow isKindOfClass:[Audio class]] && [(NSNumber *)[audioForRow valueForKey:@"replaceable"] boolValue])
        {
            if (indexPath.row == currentRecordingTrack)
            {
                [recordButton setImage:recordingImage forState:UIControlStateNormal];
            }
            else
            {
                [recordButton setImage:recordImage forState:UIControlStateNormal];
            }
        }
        
        //previously UIControlEventTouchUpInside, now 
        [recordButton addTarget:self action:@selector(recordingButtonIsPressed:) forControlEvents:UIControlEventTouchDown];
        
        trackCellRightPanel = (UIView*)[cell.contentView viewWithTag:4];
        
        
        trackCellRightIndicator = (UIView*)[cell.contentView viewWithTag:3];
        CALayer *layer = trackCellRightIndicator.layer;
        layer.sublayers = nil; //remove all the sublayers inside the layer. if not we will keep adding additional layers.
       // NSArray *layerArray = trackCellRightPanel.layer.sublayers; //get the array of layers
        
        if (indexPath.row == currentRecordingTrack && isRecording == YES)
        {
            /* draw the gradient-ed background of red to black */
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = trackCellRightIndicator.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor redColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
            [trackCellRightIndicator.layer insertSublayer:gradient atIndex:0];          
        }
        else if (isRecording == NO && isPlaying == YES)
        {      
            if ([thePlayer busNumberIsMuted:indexPath.row])
            {
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = trackCellRightIndicator.bounds;
                gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
                [trackCellRightIndicator.layer insertSublayer:gradient atIndex:0];
            }
            else
            {
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = trackCellRightIndicator.bounds;
                gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:34/255.0 green:139/255.0 blue:34/255.0 alpha:1] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
                [trackCellRightIndicator.layer insertSublayer:gradient atIndex:0];
            }
        }
        else
        {            
            /* draw the gradient-ed background of white to black */
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = trackCellRightIndicator.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
            [trackCellRightIndicator.layer insertSublayer:gradient atIndex:0];
        }    
        
        [trackCellRightPanel bringSubviewToFront:rightPanelButton];
        [rightPanelButton release];
        return cell;
        
    }
    else
    {
        //rows that are supposed to be blank (only for the last 2 rows) 
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BlankCellIdentifier];
        
        if (cell == nil)
        {
            //create all the new objects
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:BlankCellIdentifier] autorelease];
            
            cell.contentView.backgroundColor = [UIColor blackColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        return cell;
    }
}

//This method is for you to set the height of the table view.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark audio manipulation and recording methods

#pragma mark KVO callbacks
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)changeContext
{
    NSLog(@"Inside observeValueForKeyPath");
    
    NSString *kvoContext = (NSString *)changeContext;
    if ([kvoContext isEqualToString:@"NewCoverTrackAdded"])
    {
        //refresh the table
        [self performSelector:@selector(consolidateOriginalAndCoverTracks)];
        [trackTableView reloadData];
    }
}

#pragma mark IBAction events
-(void)recordingButtonIsPressed:(UIButton *)sender
{
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
    
    //if this is a recorded track, exit this method
    if ([audioForRow isKindOfClass:[CoverSceneAudio class]])
    {
        return;
    }
    
    currentRecordingTrack = row;
    isRecording = YES;
    
    //reload the tableviewcell
    [trackTableView reloadData];
    
    /* start recording once we determine it is a original track */
    Audio *trackToBeRecorded = (Audio*)audioForRow;

    NSString *tempDir = NSTemporaryDirectory();
    //we are going to use .caf files because i am going to encode in IMA4
    NSString *tempFile = [tempDir stringByAppendingFormat:@"%@-cover.caf", trackToBeRecorded.title];
    NSURL *fileURL = [NSURL fileURLWithPath:tempFile];
    
    //if file exists delete the file first
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:fileURL error:nil];
    
    self.currentRecordingNSURL = fileURL;
    self.currentRecordingTrackTitle = trackToBeRecorded.title;
    
    //scroll that row to the top
    [self scrollRowToTopOfTableView:row];
    
    [thePlayer stop];
    [thePlayer seekTo:0];
    [thePlayer stop];
    
    //start recording using MixPlayerRecorder
    [thePlayer enableRecordingToFile:fileURL];
    [thePlayer play];
    
    //display lyrics popover to come out
    [self showAndDismissLyricsButtonIsPressed];
    
    [self registerNotifications];
}

#pragma mark instance methods

- (void)resetRecordingValues
{
    currentRecordingTrackTitle = @"";
    currentRecordingNSURL = nil;
}

- (void)recordingIsCompleted
{
    
    currentRecordingTrack = -1;
    isRecording = NO;
    
    NSString *tempDir = NSTemporaryDirectory();
    NSString *tempFile = [tempDir stringByAppendingFormat:@"%@-cover.caf", currentRecordingTrackTitle];
    
    CoverSceneAudio *newCoverSceneAudio = [NSEntityDescription insertNewObjectForEntityForName:@"CoverSceneAudio" inManagedObjectContext:context];
    
    newCoverSceneAudio.title = currentRecordingTrackTitle;
    newCoverSceneAudio.path = tempFile;
    
    [self.theCoverScene addAudioObject:newCoverSceneAudio];
    
    //init the player with the original audio tracks and cover tracks
    NSMutableArray *tracksForViewNSURL = [NSMutableArray arrayWithCapacity:[tracksForView count]-1];
    
    //populate the NSURLs of each audios into an array
    [tracksForView enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Audio *anAudio = (Audio*)obj;
        NSString *path = anAudio.path;
        [tracksForViewNSURL addObject:[NSURL fileURLWithPath:path]];
    }];
    
    [self showAndDismissLyricsButtonIsPressed];
    
    [thePlayer release];
    
    //reinit the player
    thePlayer = [[MixPlayerRecorder alloc] initWithAudioFileURLs:tracksForViewNSURL];
    
    [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    
    [self resetRecordingValues];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //bring the seeker of player back to the starting point
    [thePlayer seekTo:0]; //seekTo:0 is causing the NSNotification to call this method
    [thePlayer stop];
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
            [fileManager removeItemAtURL:currentRecordingNSURL error:nil];
        }
        
        //bring the seeker of player back to the starting point
        [thePlayer seekTo:0];
        [thePlayer stop];
        
        [self showAndDismissLyricsButtonIsPressed];
               
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

/* constants related to displaying lyrics */
#define LYRICS_VIEW_WIDTH 1030 //the entire width of the landscape screen
#define LYRICS_VIEW_HEIGHT 768-200-200
#define LYRICS_VIEW_X 0
#define LYRICS_VIEW_Y 200

- (void)prepareLyricsView
{
   lyricsView = [[UIView alloc] initWithFrame:CGRectMake(LYRICS_VIEW_X, LYRICS_VIEW_Y, LYRICS_VIEW_WIDTH, LYRICS_VIEW_HEIGHT)];

    lyricsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, LYRICS_VIEW_WIDTH-40, LYRICS_VIEW_HEIGHT)]; 

    lyricsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LYRICS_VIEW_WIDTH-40, LYRICS_VIEW_HEIGHT)];

    //configure the lyrics label
    lyricsLabel.lineBreakMode = UILineBreakModeWordWrap; //line break, word wrap
	lyricsLabel.numberOfLines = 0; //0 - dynamic number of lines
    [lyricsLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:26]];
    lyricsLabel.textAlignment =  UITextAlignmentCenter;

    //configure the lyrics scroll view
    lyricsScrollView.directionalLockEnabled = YES;
    lyricsScrollView.showsHorizontalScrollIndicator = NO;
    lyricsScrollView.showsVerticalScrollIndicator = YES;
    lyricsScrollView.bounces = NO;
    [lyricsScrollView setBackgroundColor:[UIColor whiteColor]];
    
    CGRect lyricsLabelFrame = lyricsLabel.bounds; //get the CGRect representing the bounds of the UILabel
    
    lyricsLabelFrame.size = [lyrics sizeWithFont:lyricsLabel.font constrainedToSize:CGSizeMake(LYRICS_VIEW_WIDTH, 100000) lineBreakMode:lyricsLabel.lineBreakMode]; //get a CGRect for dynamically resizing the label based on the text. cool.
    
    lyricsLabel.frame = CGRectMake(0, 0, lyricsLabel.frame.size.width-10, lyricsLabelFrame.size.height); //set the new size of the label, we are only changing the height
    
    [lyricsScrollView setContentSize:CGSizeMake(lyricsLabel.frame.size.width, lyricsLabelFrame.size.height)]; //set content size of scroll view using calculated size of the text on the label
    
    [lyricsView setBackgroundColor:[UIColor blackColor]];
    
    lyricsView.alpha = 0.5;
    
    [lyricsScrollView addSubview:lyricsLabel];
    [lyricsView addSubview:lyricsScrollView];

    lyricsLabel.text = lyrics;
}

//This is for scene edit view to pass me a pointer to the play pause button
- (void)giveMePlayPauseButton:(UIButton*)aButton
{
    self.playPauseButton = aButton;
}

//Use this method to scroll a specific track cell to the top row of the table view
- (void)scrollRowToTopOfTableView:(int)row
{
    [trackTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingIsCompleted) name:kMixPlayerRecorderPlaybackStopped object:nil];
}

- (void)showAndDismissLyricsButtonIsPressed
{  
    UIView *superView = lyricsView.superview;
    
    if (superView != nil)
    {
        //if the lyrics have a super view
        [lyricsView removeFromSuperview];
    }
    else
    {
        //if the lyrics view don't have a super view
        [self.view addSubview:lyricsView];
        [self.view bringSubviewToFront:lyricsView];
        [self.view sendSubviewToBack:trackTableView];

    }
}

@end

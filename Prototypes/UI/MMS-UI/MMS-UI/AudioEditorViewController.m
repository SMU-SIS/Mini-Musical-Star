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
@synthesize lyricsPopoverController, lyricsViewController, lyricsScrollView, lyricsLabel; //released when popover is closed
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
    
    [lyrics release];
    [currentRecordingNSURL release];
    [currentRecordingTrackTitle release];
    
    //lyricsPopoverController, lyricsViewController, lyricsScrollView, lyricsLabel are released whenever the popover is closed.
    
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
        
    }
    
    return self;
}

- (void)consolidateOriginalAndCoverTracks
{
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
    
    self.view.backgroundColor = [UIColor purpleColor];
    
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
        [sender setTitle:@"Tap to Mute" forState:UIControlStateNormal];
    }
    
    else
    {
        [thePlayer muteBusNumber:busNumber];
        [sender setTitle:@"Tap to Unmute" forState:UIControlStateNormal];
    }
    
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
        
        NSLog(@"[indexPath row]: %i", [indexPath row]);
        
        //get the corresponding Audio object
        id audioForRow = [tracksForView objectAtIndex:[indexPath row]];
        
        //rows that are supposed to represent tracks
        
        //create the mute/unmute button for the track
        UIButton *rightPanelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024-150, 100)];
        [rightPanelButton setTag:[indexPath row]];
        [rightPanelButton setTitle:@"Tap to Mute" forState:UIControlStateNormal];
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
            
            
            /* the right panel of the row */
            trackCellRightPanel = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 1024-150, 100)];

            [trackCellRightPanel addSubview:rightPanelButton];
            
            [cell.contentView addSubview:trackCellRightPanel]; //add label to view

//            /* draw the gradient-ed background of white to black */
//            CAGradientLayer *gradient = [CAGradientLayer layer];
//            gradient.frame = trackCellRightPanel.bounds;
//            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
//            [trackCellRightPanel.layer insertSublayer:gradient atIndex:0];
            
            trackCellRightPanel.tag = 3;
            
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
        
        trackCellRightPanel = (UIView*)[cell.contentView viewWithTag:3];
//        CALayer *layer = trackCellRightPanel.layer;
//        layer.sublayers = nil; //remove all the sublayers inside the layer. if not we will keep adding additional layers.
////        NSArray *layerArray = trackCellRightPanel.layer.sublayers; //get the array of layers
//        
//        if (indexPath.row == currentRecordingTrack && isRecording == YES)
//        {
//            /* draw the gradient-ed background of red to black */
//            CAGradientLayer *gradient = [CAGradientLayer layer];
//            gradient.frame = trackCellRightPanel.bounds;
//            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor redColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
//            [trackCellRightPanel.layer insertSublayer:gradient atIndex:0];          
//        }
//        else if (isRecording == NO && isPlaying == TRUE)
//        {
//            //SUPPOSE TO CHECK OF THE TRACK IS MUTE ALSO
//            CAGradientLayer *gradient = [CAGradientLayer layer];
//            gradient.frame = trackCellRightPanel.bounds;
//            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor greenColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
//            [trackCellRightPanel.layer insertSublayer:gradient atIndex:0];
//        }
//        else
//        {            
//            /* draw the gradient-ed background of white to black */
//            CAGradientLayer *gradient = [CAGradientLayer layer];
//            gradient.frame = trackCellRightPanel.bounds;
//            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
//            [trackCellRightPanel.layer insertSublayer:gradient atIndex:0];
//        }    
        
        [trackCellRightPanel bringSubviewToFront:rightPanelButton];
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
    NSLog(@"Adding a new CoverSceneAudio object!\n");
    
    Audio *trackToBeRecorded = (Audio*)audioForRow;
    
    NSString *tempDir = NSTemporaryDirectory();
    //we are going to use .caf files because i am going to encode in IMA4
    NSString *tempFile = [tempDir stringByAppendingFormat:@"%@-cover.caf", trackToBeRecorded.title];
    NSURL *fileURL = [NSURL fileURLWithPath:tempFile];
    
    //if file exists delete the file first
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:fileURL error:nil];
    
    currentRecordingNSURL = fileURL;
    
    currentRecordingTrackTitle = trackToBeRecorded.title;
    
    //scroll that row to the top
    [self scrollRowToTopOfTableView:row];
    
    //start recording using MixPlayerRecorder
    [thePlayer enableRecordingToFile:fileURL];
    [thePlayer play];
    
    //display lyrics popover to come out
    [self setLyrics:trackToBeRecorded.lyrics];
    [self displayLyrics];
}

- (void)recordingIsCompleted
{
    [self dismissLyrics];
    
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
    
    [thePlayer release];
    
    //reinit the player
    thePlayer = [[MixPlayerRecorder alloc] initWithAudioFileURLs:tracksForViewNSURL];
}

- (void)userCancelled
{
    currentRecordingTrackTitle = @"";
    currentRecordingNSURL = nil;
    
}

- (void)playButtonIsPressed
{
    if (isRecording) 
    {
        
        
    }
    else if (isPlaying)
    {
        isPlaying = YES;
        [trackTableView reloadData];
    }
    
}

- (void)stopButtonIsPresssed
{
   if (isRecording) {
        currentRecordingTrack = -1;
        isRecording = NO;
        
        [trackTableView reloadData];
        
        [thePlayer stop];
        
        //clear values
        
        [self recordingIsCompleted];
    }
    else if (isPlaying)
    {
        isPlaying = NO;
        [trackTableView reloadData];
        
    }
}

#pragma mark instance methods
- (void)setLyrics:(NSString*)someLyrics
{
    lyrics = someLyrics;
}

- (void)removeLyrics
{
    [lyrics release];
}

- (bool)isRecording
{
    return isRecording;
}

/* constants related to displaying lyrics */
#define POPOVER_WIDTH 1024 //the entire width of the landscape screen
#define POPOVER_HEIGHT 200-33
#define POPOVER_ANCHOR_X 150+((1024-150)/2)
#define POPOVER_ANCHOR_Y 200

//display the lyrics in a popover, this should be called together with setLyrics:(NSString*)someLyrics
- (void)displayLyrics
{
    //I had to move 40px away from the border of the popover controller so the scroll bar of the scroll view can be seen :)
    //note: these objects are released in another method
    lyricsViewController = [[UIViewController alloc] init];
    lyricsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, POPOVER_WIDTH-40, POPOVER_HEIGHT)]; 
    lyricsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, POPOVER_WIDTH-40, POPOVER_HEIGHT)];
    
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
    
    lyricsLabel.text = lyrics;
    
    CGRect lyricsLabelFrame = lyricsLabel.bounds; //get the CGRect representing the bounds of the UILabel
    
    lyricsLabelFrame.size = [lyrics sizeWithFont:lyricsLabel.font constrainedToSize:CGSizeMake(POPOVER_WIDTH, 100000) lineBreakMode:lyricsLabel.lineBreakMode]; //get a CGRect for dynamically resizing the label based on the text. cool.
    
    lyricsLabel.frame = CGRectMake(0, 0, lyricsLabel.frame.size.width-10, lyricsLabelFrame.size.height); //set the new size of the label, we are only changing the height
    
    [lyricsScrollView setContentSize:CGSizeMake(lyricsLabel.frame.size.width, lyricsLabelFrame.size.height)]; //set content size of scroll view using calculated size of the text on the label
    
    [lyricsScrollView addSubview:lyricsLabel]; //add label to scroll view
    [lyricsViewController.view addSubview:lyricsScrollView]; //add scroll view to view controller
    
    lyricsViewController.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT); //size of the view controller’s view while displayed in a popover. this will determine the size of the popover.
    
    lyricsPopoverController = [[UIPopoverController alloc] initWithContentViewController:lyricsViewController];
    lyricsPopoverController.delegate = self;
    
    [self.lyricsPopoverController presentPopoverFromRect:CGRectMake(POPOVER_ANCHOR_X, POPOVER_ANCHOR_Y, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];    
    
    //set an array of views that the user can interact with while popover is visible
    NSMutableArray *arrayOfPassThroughViews = [NSMutableArray arrayWithCapacity:1];
    [arrayOfPassThroughViews addObject:trackTableView];
   
    for(int i=0;i<(theAudioObjects.count + theCoverScene.Audio.count + 2);i++) {
        UITableViewCell *cell = [trackTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
      if (cell != nil)
      {
       [arrayOfPassThroughViews addObject:cell];   
      }
        
        [arrayOfPassThroughViews addObject:playPauseButton];
        
    }
    
    lyricsPopoverController.passthroughViews = arrayOfPassThroughViews;
    
}

//This is for scene edit view to pass me a pointer to the play pause button
- (void)giveMePlayPauseButton:(UIButton*)aButton
{
    self.playPauseButton = aButton;
}

//Dismiss the lyrics popover controller only if it is not nil and it is visible
- (void)dismissLyrics
{
    if (lyricsPopoverController != nil && lyricsPopoverController.popoverVisible)
    {
        [lyricsPopoverController dismissPopoverAnimated:YES];
    }
}

//Use this method to scroll a specific track cell to the top row of the table view
- (void)scrollRowToTopOfTableView:(int)row
{
    [trackTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark UIPopoverControllerDelegate Protocol methods

//UIPopoverControllerDelegate Protocol method - called when the popover is dismissed.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    //release them. we don't need them after the popover is dismissed.
    [lyricsLabel release];
    [lyricsScrollView release];
    [lyricsViewController release];
    [lyricsPopoverController release];
    
    [self removeLyrics];
}

@end

//
//  AudioEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "AudioEditorViewController.h"

@implementation AudioEditorViewController
@synthesize thePlayer, theAudioObjects, theCoverScene, context, tracksForView;
@synthesize trackTableView, recordImage, recordingImage;
@synthesize lyricsPopoverController, lyricsViewController, lyricsScrollView, lyricsLabel;
@synthesize lyrics;

- (void)dealloc
{
    [thePlayer stop];
    [thePlayer release];
    [theAudioObjects release];
    [theCoverScene release];
    [tracksForView release];
    [context release];

    [trackTableView release];
    [recordImage release];
    [recordingImage release];
    
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

- (AudioEditorViewController *)initWithPlayer:(MixPlayerRecorder *)aPlayer andAudioObjects:(NSArray *)audioList andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self)
    {
        self.thePlayer = aPlayer;
        self.theAudioObjects = audioList;
        self.theCoverScene = aCoverScene;
        self.context = aContext;
        
        [self performSelector:@selector(consolidateOriginalAndCoverTracks)];
        
        //KVO the Audio NSSet
        [self.theCoverScene addObserver:self forKeyPath:@"Audio" options:0 context:@"NewCoverTrackAdded"];
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
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // If you initialize the table view with the UIView method initWithFrame:,
    //the UITableViewStylePlain style is used as a default.
    trackTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 1024, 300) style:UITableViewStylePlain];
    
    trackTableView.delegate = self;
	trackTableView.dataSource = self;
    
    trackTableView.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:trackTableView];
    
    trackTableView.separatorColor = [UIColor clearColor]; //remove borders
    
	//[trackTableView release];
    
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
    return theAudioObjects.count + theCoverScene.Audio.count;
    
}

// This method is called for each cell in the table view.
// This method is called whenever we are scrolling - try adding a NSLog to see.
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell"; //for the 3rd and subsequent rows of cells
    static NSString *blankCellIdentifier = @"BlankCell";  //for the first two rows of cells
    
    if (indexPath.row == 0 || indexPath.row == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:blankCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:blankCellIdentifier] autorelease];
            
            cell.contentView.backgroundColor = [UIColor blackColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //the cell cannot be selected
        }
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *trackNameLabel;
        UIButton *recordButton;
        TrackPane *trackCellRightPanel;
        
        if (cell == nil)
        {
            //Here, you create all the new objects
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
            
            cell.contentView.backgroundColor = [UIColor blackColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            //create the label for the track name
            trackNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 30, 200, 30)];
            trackNameLabel.backgroundColor = [UIColor blackColor];
            trackNameLabel.textColor = [UIColor whiteColor];
            [trackNameLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:18]];
            [cell.contentView addSubview:trackNameLabel]; //add label to view
            trackNameLabel.tag = 1; //tag the object to an integer value
            [trackNameLabel release];
            
            //create the record button
            recordButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 50, 50, 50)];
            [cell.contentView addSubview:recordButton];
            recordButton.tag = 2;
            [recordButton release];
            
            //create the right panel of the table cell
            trackCellRightPanel = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 1024-150, 100)];
            [cell.contentView addSubview:trackCellRightPanel]; //add label to view
            
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = trackCellRightPanel.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
            [trackCellRightPanel.layer insertSublayer:gradient atIndex:0];
            
            trackCellRightPanel.tag = 3;
            [trackCellRightPanel release];
            
        }
        
        // Here, you just configure the objects as appropriate for the row
        trackNameLabel = (UILabel*)[cell.contentView viewWithTag:1];
        trackNameLabel.text = [NSString stringWithFormat:@"Vocal %d", [indexPath row]];
        
        recordButton = (UIButton*)[cell.contentView viewWithTag:2];
        [recordButton setImage:recordImage forState:UIControlStateNormal];
        
        // 
        if (indexPath.row == currentRecordingTrack)
        {
            [recordButton setImage:recordingImage forState:UIControlStateNormal];
        }
        else
        {
            [recordButton setImage:recordImage forState:UIControlStateNormal];
        }
        
        trackCellRightPanel = (TrackPane*)[cell.contentView viewWithTag:3];
        
        //NSLog(@"there are %i", [layerArray count]);
        
        
        //need to use later, keep it
        if (indexPath.row == currentRecordingTrack)
        {
            
        }
        else
        {
            
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
    NSLog(@"Adding a new CoverSceneAudio object!\n");
    CoverSceneAudio *newCoverSceneAudio = [NSEntityDescription insertNewObjectForEntityForName:@"CoverSceneAudio" inManagedObjectContext:context];
    newCoverSceneAudio.title = @"Recorded Audio";
    NSString *recordedPath = [[NSBundle mainBundle] pathForResource:@"guitar" ofType:@"mp3"];
    newCoverSceneAudio.path = recordedPath;
    
    [self.theCoverScene addAudioObject:newCoverSceneAudio];
    
}

- (void)setLyrics:(NSString*)someLyrics
{
    lyrics = someLyrics;
}

- (void)removeLyrics
{
    [lyrics release];
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
    
}

//Use this method to scroll a specific track cell to the top row of the table view
- (void)scrollToTrack:(int)trackNumber
{
    [trackTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:trackNumber-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

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

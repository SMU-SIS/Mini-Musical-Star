//
//  AudioEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "AudioEditorViewController.h"

@implementation AudioEditorViewController
@synthesize trackTableView, lyricsPopoverController, recordImage, recordingImage, thePlayer, theAudioObjects;

- (void)dealloc
{
    [thePlayer stop];
    [thePlayer release];
    [theAudioObjects release];
    [trackTableView release];
    [lyricsPopoverController release];
    [recordImage release];
    [recordingImage release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (AudioEditorViewController *)initWithPlayer:(MixPlayerRecorder *)aPlayer andAudioObjects:(NSArray *)audioList
{
    self = [super init];
    if (self)
    {
        self.thePlayer = aPlayer;
        self.theAudioObjects = audioList;
    }
    
    return self;
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
    
	[trackTableView release];
    
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
    return theAudioObjects.count;
    
}

// This method is called for each cell in the table view.
// This method is called whenever we are scrolling - try adding a NSLog to see.
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell"; //for the 3rd and subsequent rows of cells
    static NSString *blankCellIdentifier = @"BlankCell";  //for the first two rows of cells
    
    //if (indexPath.row == 0 || indexPath.row == 1)
    if (false)
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
        
        //get the corresponding Audio object
        Audio *audioForRow = [theAudioObjects objectAtIndex:[indexPath row]];
        
        if (cell == nil)
        {
            //Here, you create all the new objects
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
            
            cell.contentView.backgroundColor = [UIColor blackColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            trackNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 30, 200, 30)];
            trackNameLabel.backgroundColor = [UIColor blackColor];
            trackNameLabel.textColor = [UIColor whiteColor];
            [trackNameLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:18]];
            [cell.contentView addSubview:trackNameLabel]; //add label to view
            trackNameLabel.tag = 1; //tag the object to an integer value
            [trackNameLabel release];
            
            if ([audioForRow.replaceable boolValue])
            {
                recordButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 50, 50, 50)];
                [cell.contentView addSubview:recordButton];
                recordButton.tag = 2;
                [recordButton release];  
            }
            
            trackCellRightPanel = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 1024-150, 100)];
            [cell.contentView addSubview:trackCellRightPanel]; //add label to view
            trackCellRightPanel.tag = 3;
            [trackCellRightPanel release];
            
        }
        
        // Here, you just configure the objects as appropriate for the row
        trackNameLabel = (UILabel*)[cell.contentView viewWithTag:1];
        //trackNameLabel.text = [NSString stringWithFormat:@"Vocal %d", [indexPath row]];
        
        trackNameLabel.text = audioForRow.title;
        
        recordButton = (UIButton*)[cell.contentView viewWithTag:2];
        [recordButton setImage:recordImage forState:UIControlStateNormal];
        
        
        if (indexPath.row == currentRecordingTrack)
        {
            [recordButton setImage:recordingImage forState:UIControlStateNormal];
        }
        else
        {
            [recordButton setImage:recordImage forState:UIControlStateNormal];
        }
        
        trackCellRightPanel = (TrackPane*)[cell.contentView viewWithTag:3];
        if (indexPath.row == currentRecordingTrack)
        {
            /* draw the gradient-ed background of white to black */
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = trackCellRightPanel.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor redColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];            
            [trackCellRightPanel.layer insertSublayer:gradient atIndex:0];
            
            NSArray *layerArray = trackCellRightPanel.layer.sublayers;
            CALayer *currLayer = [layerArray objectAtIndex:0]; //gets reference to the old layer, HA!
            [trackCellRightPanel.layer replaceSublayer:currLayer with:gradient];
            
        }
        else
        {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = trackCellRightPanel.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
            [trackCellRightPanel.layer insertSublayer:gradient atIndex:0];
            
            NSArray *layerArray = trackCellRightPanel.layer.sublayers;
            CALayer *currLayer = [layerArray objectAtIndex:0]; //gets reference to the old layer, HA!
            [trackCellRightPanel.layer replaceSublayer:currLayer with:gradient];
            
            NSLog(@"there are %i", [layerArray count]);
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

@end

//
//  PlayNewUIViewController.m
//  PlayNewUI
//
//  Created by Tommi on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayNewUIViewController.h"
#import "TrackPane.h"
#import "LyricsViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation PlayNewUIViewController

@synthesize trackTableView, trackCellRightPanel, lyricsPopoverController, recordImage, recordingImage;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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


#pragma mark Table view methods

// We will only have 1 section, so don't change the value here.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

// This method is called for each cell in the table view.
// This method is called whenever we are scrolling - try adding a NSLog to see.
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"";
    
    CellIdentifier = [NSString stringWithFormat:@"Cell%i", [indexPath row]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        
        switch ([indexPath row]) {
            case 0:
                cell.contentView.backgroundColor = [UIColor blackColor];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //the cell cannot be selected
                break;
            case 1:
                cell.contentView.backgroundColor = [UIColor blackColor];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                break;
                
            default:
                cell.contentView.backgroundColor = [UIColor blackColor];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                UILabel *trackNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 30, 200, 30)];
                NSLog(@"[indexPath row] to be printed: %i", [indexPath row]);
                trackNameLabel.text = [NSString stringWithFormat:@"Vocal %d", [indexPath row]];
                trackNameLabel.backgroundColor = [UIColor blackColor];
                trackNameLabel.textColor = [UIColor whiteColor];
                [trackNameLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:18]];
                [cell.contentView addSubview:trackNameLabel]; //add label to view
                [trackNameLabel release];
                
                UIButton *recordButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 50, 40, 40)];
                [recordButton setImage:recordImage forState:UIControlStateNormal];
                [cell.contentView addSubview:recordButton];
                [recordButton release];
                
                trackCellRightPanel = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 1024-150, 100)];
                
                /* draw gradient background */
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = trackCellRightPanel.bounds;
                gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
                [trackCellRightPanel.layer insertSublayer:gradient atIndex:0];
                [cell.contentView addSubview:trackCellRightPanel]; //add label to view
                
                break;
        }
        
    }    
    
          
    //WHICH VARIABLE I HAVE TO RELEASE?!!?!?!?!? 
    
    return cell;
}

//This method is for you to set the height of the table view.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

//This IBAction method has to has to be transferred
- (IBAction)scrollToX
{
    [trackTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:8 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//This IBAction method has to has to be transferred
- (IBAction)lyricsAppear
{
    //Preferred width of popover: 1024-150
    //Preferred height of popover: 300 (100 from the empty space on top, 200 from the first 2 rows)
    
    LyricsViewController *lyricsViewController = [[LyricsViewController alloc] init];
    
    lyricsViewController.contentSizeForViewInPopover = CGSizeMake(1024-150-35, 300-33); //size of the view controller’s view while displayed in a popover
    //note, the size (1024-150-35, 300-33) is decided to ensure the width sits within the center of the vocal track right panels and the height is to ensure it covers the portion of the screen from the top till the top of the current vocal.
    
    lyricsPopoverController = [[UIPopoverController alloc] initWithContentViewController:lyricsViewController];
    
    [self.lyricsPopoverController presentPopoverFromRect:CGRectMake(150+((1024-150)/2), 0, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];    
    
    [lyricsViewController release];
}

- (IBAction)startRecording
{
    NSLog(@"inside: - (IBAction)startRecording");
    
    //assume vocal 5 is recording
    currentRecordingTrack = 5;
}

- (IBAction)stopRecording
{
    NSLog(@"inside: - (IBAction)stopRecording");
    
    //cancel all recording
    currentRecordingTrack = -1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [lyricsPopoverController release];
    [recordImage release];
    [recordingImage release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end

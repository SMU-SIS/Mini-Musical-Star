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

@synthesize trackTableView, trackCellRightPanel, lyricsPopoverController;

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
    
    //0, 100, 1024, 300
    // If you initialize the table view with the UIView method initWithFrame:,
    //the UITableViewStylePlain style is used as a default.
    trackTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 1024, 300) style:UITableViewStylePlain];
    
    trackTableView.delegate = self;
	trackTableView.dataSource = self;
    
    trackTableView.backgroundColor = [UIColor blackColor];

    [self.view addSubview:trackTableView];
    
    trackTableView.separatorColor = [UIColor clearColor]; //remove borders
    
	[trackTableView release];
}


#pragma mark Table view methods

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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }    
    
    switch ([indexPath row]) {
        case 0:
            cell.contentView.backgroundColor = [UIColor blackColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //the cell cannot be selected

            break;
            
        default:
            cell.contentView.backgroundColor = [UIColor blackColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //the cell cannot be selected
            
            UILabel *trackNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 30, 200, 30)];
            trackNameLabel.text = [NSString stringWithFormat:@"Vocal %d", [indexPath row]];
            trackNameLabel.backgroundColor = [UIColor blackColor];
            trackNameLabel.textColor = [UIColor whiteColor];
            [trackNameLabel setFont:[UIFont fontWithName:@"GillSans-Bold" size:18]];
            [cell.contentView addSubview:trackNameLabel]; //add label to view
            [trackNameLabel release];
            
            
            UIButton *recordButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 50, 40, 40)];
            UIImage *recordImage = [UIImage imageNamed:@"record.png"];
            [recordButton setImage:recordImage forState:UIControlStateNormal];
            [cell.contentView addSubview:recordButton];
            
            trackCellRightPanel = [[UIView alloc] initWithFrame:CGRectMake(150, 0, 1024-150, 100)];
            
            /* draw gradient background */
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = trackCellRightPanel.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
            [trackCellRightPanel.layer insertSublayer:gradient atIndex:0];
            [cell.contentView addSubview:trackCellRightPanel]; //add label to view
            

            
            break;
    }
    
      
    //WHICH VARIABLE I HAVE TO RELEASE?!!?!?!?!? 
    
    return cell;
}

//This method is for you to set the height of the table view.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (IBAction)scrollToX
{
    [trackTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:8 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


- (IBAction)lyricsAppear
{
    //width: 1024-150
    //height: 300 - 100 from the empty space on top, 200 from the first 2 roles
    UIView *lyricsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024-150, 300)];
    lyricsView.backgroundColor = [UIColor lightGrayColor];
    
    LyricsViewController *lyricsViewController = [[LyricsViewController alloc] init];
    *lyricsPopoverController = [[UIPopoverController alloc] initWithContentViewController:lyricsViewController];
    
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

@end

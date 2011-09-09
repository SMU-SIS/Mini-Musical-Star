//
//  PlayNewUIViewController.m
//  PlayNewUI
//
//  Created by Tommi on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayNewUIViewController.h"
#import "TrackPane.h"

@implementation PlayNewUIViewController

@synthesize tableView;
@synthesize handsomeArray;

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

    handsomeArray = [[NSMutableArray alloc] init];
    
    [handsomeArray addObject:@"tommi is handsome"];
    [handsomeArray addObject:@"tommi is really handsome"];
    [handsomeArray addObject:@"tommi is awesome"];
    [handsomeArray addObject:@"tommi is really awesome"];
    [handsomeArray addObject:@"tommi is hot"];
    [handsomeArray addObject:@"tommi is really hot"];
    [handsomeArray addObject:@"tommi is sexy"];
    [handsomeArray addObject:@"tommi is really sexy"];
}

- (void)loadView
{
	//a sample code....
	UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];//UITableViewStylePlain, UITableViewStyleGrouped
    
	tableView.delegate = self;
	tableView.dataSource = self;
    
	self.tableView = tableView;
	self.view = tableView;
	[tableView release];	
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [handsomeArray count];
}

// This method is called for each cell in the table view.
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CustomCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }    
    
    NSUInteger row = [indexPath row];   //get the index of each row
    NSLog(@"row: %i", row);
    
    cell.primaryLabel.text = @"TOMMI IS HANDSOME";
    cell.secondaryLabel.text = @"WOOHOO";
    cell.myImageView.image = [UIImage imageNamed:@"23-bird.png"];
    
    
    UIView *trackPaneView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 100)] autorelease];
    [trackPaneView setBackgroundColor:[UIColor blueColor]];
    
    UILabel *trackNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
    trackNameLabel.text = @"Vocal One";
    [trackPaneView addSubview:trackNameLabel]; //add label to view
    
    UIButton *testButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 10, 100, 30)];
    [testButton addTarget:self action:@selector(buttonIsPressed:) forControlEvents:UIControlEventTouchDown];
    [testButton setTitle:@"AWESOME" forState:UIControlStateNormal];
    [testButton setBackgroundColor:[UIColor greenColor]];
    [trackPaneView addSubview:testButton]; //add button to view
    
    //trackPaneView.tableViewCell = cell;
    
    [cell.contentView addSubview:trackPaneView]; //add entire view to content view of table cel view
    
    

//    //this is how you handle a original table view cell  
//    NSString *cellLabel = [handsomeArray objectAtIndex:[indexPath row]];
//    [cell.textLabel setText:cellLabel];
//    [cell.detailTextLabel setText:@"you are wow"];
//    [cellLabel release]; //bye!
    
    
    return cell;
}

//This method is for you to set the height of the table view.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (IBAction)buttonIsPressed:(id)sender 
{
    NSLog(@"fsfjsfj");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [handsomeArray release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end

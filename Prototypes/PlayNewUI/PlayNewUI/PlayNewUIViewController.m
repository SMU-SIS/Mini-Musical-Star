//
//  PlayNewUIViewController.m
//  PlayNewUI
//
//  Created by Tommi on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayNewUIViewController.h"

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

- (void)loadView {
	
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
    return 8;
}

// This method is called for each cell in the table view.
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSUInteger row = [indexPath row];   //get the index of each row
    NSLog(@"row: %i", row);
    
    
    // Set up the cell...
    
    
    NSString *cellLabel = [handsomeArray objectAtIndex:[indexPath row]];
    [cell.textLabel setText:cellLabel];
    [cell.detailTextLabel setText:@"you are wow"];
    [cellLabel release]; //bye!
    
    
    return cell;
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

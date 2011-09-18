//
//  SimpleTableViewController.m
//  SimpleTable
//
//  Created by Adeem on 17/05/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SimpleTableViewController.h"
#import "TableCellView.h"
@implementation SimpleTableViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	arryData = [[NSArray alloc] initWithObjects:@"Vocal 1",@"Vocal 2",@"Vocal 3",nil];
	self.title = @"Simple Table Exmaple";
    
    [self setTable];
    
    [super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arryData count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   /* 
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.text = [arryData objectAtIndex:indexPath.row];
    return cell;*/
	static NSString *MyIdentifier = @"MyIdentifier";
	MyIdentifier = @"tblCellView";
	
	TableCellView *cell = (TableCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"TableCellView" owner:self options:nil];
		cell = tblCell;
	}
	
	[cell setLabelText:[arryData objectAtIndex:indexPath.row]];
    [cell setButtonTag:indexPath.row];
	return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor blackColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/*This part is for what happens after selecting a row.
     
    NextViewController *nextController = [[NextViewController alloc] initWithNibName:@"NextView" bundle:nil];
	[self.navigationController pushViewController:nextController animated:YES];
	[nextController changeProductText:[arryData objectAtIndex:indexPath.row]];
    */
    UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor greenColor]];

}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Reserved for deselection of a cell.
    UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];

    [cell setBackgroundColor:[UIColor blackColor]];
}



-(void)setTable
{
    tblSimpleTable.backgroundColor = [UIColor blackColor];
    tblSimpleTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblSimpleTable.rowHeight = 80;
}

@end

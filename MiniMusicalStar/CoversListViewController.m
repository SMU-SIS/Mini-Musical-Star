//
//  CoversListViewController.m
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 3/10/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "CoversListViewController.h"

@implementation CoversListViewController
@synthesize delegate, theShow, context, frc;

- (void)dealloc
{
    [frc release];
    [theShow release];
    [context release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithShow:(Show *)aShow context:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self)
    {
        self.theShow = aShow;
        self.context = aContext;
        [self createFetchedResultsController];
    }
    
    return self;
}

- (void)createFetchedResultsController
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Cover" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    [request setFetchBatchSize:20];
    
    //predicate...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(coverOfShowHash == %@)", theShow.showHash];
    NSLog(@"%@", predicate);
    [request setPredicate:predicate];
    
    //sort descriptor...
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:descriptors];
    
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = self;
    
    self.frc = fetchedResultsController;
    
    [fetchedResultsController release], fetchedResultsController = nil;

}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) populateTable{
    NSError *error;
    if (![[self frc] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self populateTable];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(flipCoversBackToFront:)];          
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    [super viewWillAppear:animated];

}

- (void)flipCoversBackToFront:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(dismissCoversList)])
    {
        [self.delegate performSelector:@selector(dismissCoversList)];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (int)numberOfCovers
{
    return [[[frc sections] objectAtIndex:0] numberOfObjects];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [[frc sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
    sectionInfo = [[frc sections] objectAtIndex:section];
    NSLog(@"we have %i objects in database", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        // Configure the cell...
        [self configureCell:cell atIndexPath:indexPath];
    }

    

    return cell;
}

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    NSManagedObject *mo = nil;
    NSString *temp = nil;
    mo = [frc objectAtIndexPath:indexPath];
    temp = [[mo valueForKey:@"title"] description]; 
    [[cell textLabel] setText:temp];
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    
    UIButton *selectExportButton = [[UIButton alloc] initWithFrame:CGRectMake(220,8,96,32)];
    [selectExportButton setImage:[UIImage imageNamed:@"export.png"] forState:UIControlStateNormal];
    [selectExportButton addTarget:delegate action:@selector(showMediaManagement:) forControlEvents:UIControlEventTouchUpInside];
    [selectExportButton setTag:indexPath.row];
    [cell.contentView addSubview:selectExportButton];
}

//called when there is a change in the covers list
-(void)controller:(NSFetchedResultsController *)controller 
  didChangeObject:(id)anObject 
      atIndexPath:(NSIndexPath *)indexPath 
    forChangeType:(NSFetchedResultsChangeType)type 
     newIndexPath:(NSIndexPath *)newIndexPath;
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationTop];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationTop];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Cover *selectedCover = [frc objectAtIndexPath:indexPath];
        [selectedCover purgeRelatedFiles];
        [self.context deleteObject:selectedCover];
        
        NSError *err = nil;
        if (![self.context save:&err])
        {
            NSLog(@"Deletion error occured: %@", err);
        }
    }   
}

/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{

}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (Cover*) getSelectedCover: (NSIndexPath *)indexPath
{
    return [frc objectAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cover *selectedCover = [frc objectAtIndexPath:indexPath];
    [delegate performSelector:@selector(loadSceneSelectionScrollViewWithCover:) withObject:selectedCover];
}

@end

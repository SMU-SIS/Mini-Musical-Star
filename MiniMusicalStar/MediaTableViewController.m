//
//  MediaTableViewController.m
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 31/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaTableViewController.h"
#import "ExportedAsset.h"

@implementation MediaTableViewController

@synthesize delegate;
@synthesize exportedAssetArray;
@synthesize context;
@synthesize theCover;
@synthesize frc;
@synthesize youtubeUploadImage;
@synthesize facebookUploadImage;

- (void)dealloc
{
    [theCover release];
    [facebookUploadImage release];
    [youtubeUploadImage release];
    [frc release];
    [context release];
    [exportedAssetArray release];
    [delegate release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style withCover:(Cover*)cover withContext:(NSManagedObjectContext*)ctxt
{
    self = [super initWithStyle:style];
    if (self) {
        self.context = ctxt;
        self.theCover = cover;
        [self createFetchedResultsController];
        facebookUploadImage = [UIImage imageNamed:@"facebook_32.png"];
        youtubeUploadImage = [UIImage imageNamed:@"youtube_32.png"];
    }
    return self;
}

       
- (void)createFetchedResultsController
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ExportedAsset" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    [request setFetchBatchSize:20];
    
    //predicate...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(originalHash == %@)", theCover.originalHash];
    NSLog(@"%@", predicate);
    [request setPredicate:predicate];
    
    //sort descriptor...
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
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

#pragma mark - View lifecycle

- (void) populateTable{
    NSError *error;
    if (![[self frc] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}

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
    [super viewWillAppear:animated];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[frc sections] count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
    sectionInfo = [[frc sections] objectAtIndex:section];
//    NSLog(@"we have %i objects in MEDIA TABLE VIEW", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (int)numberOfExportedAssets
{
    return [[[frc sections] objectAtIndex:0] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
 
    UIButton *facebookUploadButton;
    UIButton *youtubeUploadButton;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //create the accessory view with the fb and youtube upload buttons
        UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 70)];
        
        facebookUploadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 50, 50)];
        [facebookUploadButton setImage:self.facebookUploadImage forState:UIControlStateNormal];
        facebookUploadButton.tag = 1;
        [accessoryView addSubview:facebookUploadButton];
        //[cell.accessoryView addSubview:facebookUploadButton];
        [facebookUploadButton release];
        
        youtubeUploadButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 10, 50, 50)];
        [youtubeUploadButton setImage:self.youtubeUploadImage forState:UIControlStateNormal];
        [accessoryView addSubview:youtubeUploadButton];
        youtubeUploadButton.tag = 2;
        [youtubeUploadButton release];
        
        [facebookUploadButton addTarget:self action:@selector(facebookUploadButtonIsPressed:) 
                       forControlEvents:UIControlEventTouchDown];
        [youtubeUploadButton addTarget:self action:@selector(youtubeUploadButtonIsPressed:) 
                      forControlEvents:UIControlEventTouchDown];
        
        [cell setAccessoryView:accessoryView];
        
        [accessoryView release];
    }
    
    // Configure the cell...
    NSManagedObject *mo = [frc objectAtIndexPath:indexPath];
    NSString *title = [[mo valueForKey:@"title"] description];
    NSDate *date = [mo valueForKey:@"dateCreated"];
    NSString *dateCreated = [date descriptionWithLocale:[NSLocale currentLocale]];
    
    UIImage *background = [UIImage imageNamed: @"export_cell.png"];
    cell.backgroundColor = [[UIColor alloc] initWithPatternImage:background];
    [[cell textLabel] setText:title];
    [[cell detailTextLabel] setText:dateCreated];
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
//    //hide all the buttons in the accessory view
//    [cell.accessoryView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UIView *aView = (UIView *)obj;
//        aView.hidden = YES;
//    }];
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        ExportedAsset *assetForDeletion = [frc objectAtIndexPath:indexPath];
        [assetForDeletion deleteExportFile];
        
        //remove it from core data
        [self.context deleteObject:assetForDeletion];
        
        NSError *err = nil;
        if (![self.context save:&err])
        {
            NSLog(@"Deletion error occured: %@", err);
        }
        
        NSLog(@"deletion is done");
        
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    

    ExportedAsset *selectedExportedAsset = [frc objectAtIndexPath:indexPath];
    NSURL *assetURL = [NSURL URLWithString:selectedExportedAsset.exportPath];

    //ExportedAsset *selectedExportedAsset = [frc objectAtIndexPath:indexPath];
    
    [delegate performSelector:@selector(playMovie:) withObject:assetURL];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma instance methods

- (void)facebookUploadButtonIsPressed:(UIButton*)sender
{
    ExportedAsset *selectedAsset = (ExportedAsset*)[self.frc objectAtIndexPath:[self getIndexPath:sender]];
    NSURL *url = [NSURL URLWithString:selectedAsset.exportPath];
    [self.delegate uploadToFacebook:url];
}

- (void)youtubeUploadButtonIsPressed:(UIButton*)sender
{
    ExportedAsset *selectedAsset = (ExportedAsset*)[self.frc objectAtIndexPath:[self getIndexPath:sender]];
    NSURL *url = [NSURL URLWithString:selectedAsset.exportPath];
    [self.delegate uploadToYouTube:url];
}

- (NSIndexPath*)getIndexPath:(UIButton*)sender
{
    UITableViewCell *cell = (UITableViewCell*)sender.superview.superview;
    UITableView *table = (UITableView*)cell.superview;
    return [table indexPathForCell:cell];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"controller did change content!");
}

@end

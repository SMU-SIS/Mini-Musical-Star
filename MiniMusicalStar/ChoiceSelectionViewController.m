//
//  ChoiceSelectionViewController.m
//  MiniMusicalStar
//
//  Created by Wei Jie Tan on 11/10/11.
//  Copyright 2011 weijie.tan.2009@gmail.com. All rights reserved.
//

#import "ChoiceSelectionViewController.h"

@implementation ChoiceSelectionViewController
@synthesize theShow;
@synthesize managedObjectContext;
@synthesize frc;
@synthesize showTitle, showDescription;
@synthesize exportTableController;
@synthesize mediaManagementButton;
@synthesize currentSelectedCoversList;
@synthesize coverName;

- (void)dealloc
{
    [exportTableController release];
    [showCover release];
    [theShow release];
    [create release];
    [cover release];
    [showTitle release];
    [showDescription release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(ChoiceSelectionViewController *)initWithAShowForSelection:(Show *)aShow context:(NSManagedObjectContext *)aContext
{
    [super init];
    //store the current show as an ivar
    self.theShow = aShow;
    self.managedObjectContext = aContext;
    //[self loadCoversForShow:theShow];
    
    UIView *parentView = self.view;
    
    CGRect coversFrame;
    coversFrame.origin.x = 500;
    coversFrame.origin.y = 0;
    coversFrame.size.width = 500;
    coversFrame.size.height = parentView.frame.size.height;
    
    CoversListViewController *coversView = [[CoversListViewController alloc] initWithShow:self.theShow context:self.managedObjectContext];
    coversView.view.frame = coversFrame;
    coversView.delegate = self;
    
    self.currentSelectedCoversList = [[UINavigationController alloc] initWithRootViewController:coversView];
    self.currentSelectedCoversList.view.frame = coversFrame;
    
    [coversView release];
    
    return self;
}

- (IBAction)promptForCoverName: (UIButton*)sender
{
    AlertPrompt *prompt = [AlertPrompt alloc];
	prompt = [prompt initWithTitle:@"Give your cover a name!" message:@" " delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"Okay"];
	[prompt show];
	[prompt release];

}

- (void)createMusical
{
    if ([coverName length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OPPS!" message:@"Please enter something!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
        [alert show];
        [alert release]; 
    }
    else
    {
    Cover *newCover = [NSEntityDescription insertNewObjectForEntityForName:@"Cover" inManagedObjectContext:managedObjectContext];
    newCover.cover_of_showHash = [theShow showHash];

        
    SceneViewController *sceneView = [[SceneViewController alloc] initWithScenesFromShow:theShow andCover:newCover andContext:managedObjectContext];
    
    newCover.title = coverName;
    
    NSError *error;
    [managedObjectContext save:&error];
        
        NSLog(@"Covername is %@", coverName);
    
    sceneView.title = [theShow title];
    
    [self.navigationController pushViewController:sceneView animated:YES];
    
    [sceneView release];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mediaManagementButton = [[UIBarButtonItem alloc] initWithTitle:@"Export Musicals" style:UIBarButtonItemStylePlain target:self action:@selector(showMediaManagement:)];          
    self.navigationItem.rightBarButtonItem = mediaManagementButton;
    
    showCover.image = theShow.coverPicture;
    
    self.showTitle.text = self.theShow.title;
    self.showDescription.text = self.theShow.showDescription;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //show the navigation bar
    self.navigationController.navigationBarHidden = NO;
}

-(void) showMediaManagement: (id)sender{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    exportTableController = [[ExportTableViewController alloc] initWithStyle:UITableViewStyleGrouped:theShow
                            :
                             [NSEntityDescription insertNewObjectForEntityForName:@"Cover" inManagedObjectContext:managedObjectContext]];
    [self.navigationController pushViewController:exportTableController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];    
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

- (void)loadCoversForShow:(Show *)aShow
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Cover" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    [request setFetchBatchSize:20];
    
    //predicate...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cover_of_showHash == %@", theShow.showHash];

    [request setPredicate:predicate];
    
    //error here, the ID doesnt match with the shows
    NSLog(@"The show ID is %@", aShow.showHash);
    NSLog(@"The show is KNS %@", aShow.title);
    
    //sort descriptor...
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:descriptors];
    
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    fetchedResultsController.delegate = self;
    
    self.frc = fetchedResultsController;
    
    NSError *error;
    [frc performFetch:&error];
    
    [fetchedResultsController release], fetchedResultsController = nil;
}


- (IBAction)loadCoversList:(UIButton *)sender
{

    
    NSLog(@"the selected show is %@", theShow.title);
    
    if ([(CoversListViewController *)[self.currentSelectedCoversList topViewController] numberOfCovers] == 0) 
    {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OPPS!" message:@"Please create your first cover!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
    }
    
    else
    {
     
        //NSLog(@"number of objects is  %i", [[[self.frc sections] objectAtIndex:0] numberOfObjects]);

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        [UIView setAnimationDuration:1.0];
        
        [UIView commitAnimations];    
        [self.view addSubview:self.currentSelectedCoversList.view];
    
    }
}

- (void)dismissCoversList
{
    [self.currentSelectedCoversList.view removeFromSuperview];
    //self.currentSelectedCoversList = nil;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex])
	{
		coverName = [(AlertPrompt *)alertView enteredText];
        [self createMusical];
	}
}

-(void)selectedSavedCover:(Cover*)aCover
{
    SceneViewController *sceneView = [[SceneViewController alloc] initWithScenesFromShow:theShow andCover:aCover andContext:managedObjectContext];
    
    sceneView.title = [aCover title];
    
    [self.navigationController pushViewController:sceneView animated:YES];
    
    [sceneView release];
}
@end

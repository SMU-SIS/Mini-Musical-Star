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
@synthesize currentSelectedCoversList;
@synthesize currentSelectedMusical;
@synthesize frc;

- (void)dealloc
{
    [showCover release];
    [theShow release];
    [create release];
    [cover release];
    
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
    return self;
}

- (IBAction)createMusical: (UIButton*)sender {
    
    Cover *newCover = [NSEntityDescription insertNewObjectForEntityForName:@"Cover" inManagedObjectContext:managedObjectContext];
    newCover.cover_of_showID = [NSNumber numberWithInt:[theShow showID]];
    
    SceneViewController *sceneView = [[SceneViewController alloc] initWithScenesFromShow:theShow andCover:newCover andContext:managedObjectContext];

    
    sceneView.title = [theShow title];
    
    [self.navigationController pushViewController:sceneView animated:YES];
    
    [sceneView release];
}

- (IBAction)listCoversForMusical:(UIButton*)sender
{
    
    UIView *parentView = self.view;
    
    CGRect coversFrame;
    coversFrame.origin.x = 542;
    coversFrame.origin.y = 0;
    coversFrame.size.width = 500;
    coversFrame.size.height = parentView.frame.size.height;
    
    //NSLog(@"KNS AGAIN %i", [[[frc sections] objectAtIndex:0] numberOfObjects]);
    
    if ([[[frc sections] objectAtIndex:0] numberOfObjects] == 0) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OPPS!" message:@"Please create your first cover!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else
    {
        CoversListViewController *coversView = [[CoversListViewController alloc] initWithShow:theShow context:self.managedObjectContext];
        coversView.view.frame = coversFrame;
        coversView.delegate = self;

        UINavigationController *coversListNavController = [[UINavigationController alloc] initWithRootViewController:coversView];
        coversListNavController.view.frame = coversFrame;
    
        self.currentSelectedCoversList = coversListNavController;
        [self.currentSelectedMusical removeFromSuperview];
       
    
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:parentView cache:YES];
        [UIView setAnimationDuration:1.0];
    
        //CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
        //parentView.transform = transform;
    
        [UIView commitAnimations];
        [parentView addSubview:coversListNavController.view]; 
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    showCover.image = theShow.coverPicture;
    [self loadCoversForShow:theShow];    
    
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
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Cover" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    [request setFetchBatchSize:20];
    
    //predicate...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cover_of_showID == %i", aShow.showID];
    [request setPredicate:predicate];
    
    //sort descriptor...
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:descriptors];
    
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    fetchedResultsController.delegate = self;
    
    self.frc = fetchedResultsController;
    
    NSError *error;
    if (![[self frc] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"WEIJIE %@, %@", error, [error userInfo]);
	}
    
    [fetchedResultsController release], fetchedResultsController = nil;

}

@end

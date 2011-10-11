//
//  NewOpenViewController.m
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 11/10/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "NewOpenViewController.h"

#import "Show.h"
#import "Cover.h"
#import "SceneViewController.h"

@implementation NewOpenViewController
@synthesize theShow, context, frc;

-(void)dealloc
{
    [theShow release];
    [context release];
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
        
        self.title = self.theShow.title;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)createNewMusicalButtonPressed:(UIButton *)sender
{
    Cover *newCover = [NSEntityDescription insertNewObjectForEntityForName:@"Cover" inManagedObjectContext:self.context];
    newCover.cover_of_showID = [NSNumber numberWithInt:theShow.showID];
    
    [self loadShowWithCover:newCover];

}

- (void)loadShowWithCover:(Cover *)aCover
{
    //instantiate the next view controller
    SceneViewController *sceneView = [[SceneViewController alloc] initWithScenesFromShow:self.theShow andCover:aCover andContext:self.context];
    
    [self.navigationController pushViewController:sceneView animated:YES];
    [sceneView release];
}

- (void)loadCoversForShow:(Show *)aShow
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Cover" inManagedObjectContext:self.context];
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
    
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:@"Root"];
    fetchedResultsController.delegate = self;
    
    self.frc = fetchedResultsController;
    [fetchedResultsController release], fetchedResultsController = nil;
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

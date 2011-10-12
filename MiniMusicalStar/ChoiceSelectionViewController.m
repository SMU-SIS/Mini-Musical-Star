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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    showCover.image = theShow.coverPicture;
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

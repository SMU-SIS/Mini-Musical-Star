//
//  ChoiceSelectionViewController.m
//  MiniMusicalStar
//
//  Created by Wei Jie Tan on 11/10/11.
//  Copyright 2011 weijie.tan.2009@gmail.com. All rights reserved.
//

#import "ChoiceSelectionViewController.h"
#import "DSActivityView.h"

@implementation ChoiceSelectionViewController
@synthesize theShow;
@synthesize managedObjectContext;
@synthesize frc;
@synthesize showTitle, showDescription;
@synthesize exportTableController;
@synthesize mediaManagementButton;
@synthesize currentSelectedCoversList;
@synthesize coverName;
@synthesize sceneMenu;

- (void)dealloc
{
    [sceneMenu release];
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
//    [self loadSceneSelectionScrollView];
    self.sceneMenu = [[UIScrollView alloc] initWithFrame:CGRectMake(1024,450,1024,200)];
    UIButton *tempButtonToSlide = [[UIButton alloc] initWithFrame:CGRectMake(500,200,400,100)];
    [self.view addSubview:tempButtonToSlide];
    [tempButtonToSlide setTitle:@"click me to slide! hee" forState:UIControlStateNormal];
    [tempButtonToSlide addTarget:self action:@selector(loadSceneSelectionScrollView) forControlEvents:UIControlEventTouchUpInside];
    
    
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
    newCover.coverOfShowHash = [theShow showHash];

        
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

-(void) removeSceneMenu
{
    [self.sceneMenu removeFromSuperview];
}

- (void)loadSceneSelectionScrollView
{
    if (self.sceneMenu.superview != nil){
        [UIView animateWithDuration:0.5 animations:^(void) {
            CGAffineTransform moveRight = CGAffineTransformMakeTranslation(1024, 0);
            self.sceneMenu.transform = moveRight;
        }];
        
        [self performSelector:@selector(removeSceneMenu) withObject:self afterDelay:0.5];
        return;
    }
    self.sceneMenu.backgroundColor = [UIColor blueColor];
    self.sceneMenu.scrollEnabled = YES;
    self.sceneMenu.showsHorizontalScrollIndicator = NO;
    self.sceneMenu.showsVerticalScrollIndicator = NO;
    self.sceneMenu.pagingEnabled = NO;
    self.sceneMenu.clipsToBounds = NO;
    [self.view addSubview:self.sceneMenu];
    [UIView animateWithDuration:0.5 animations:^(void) {
        CGAffineTransform moveLeft = CGAffineTransformMakeTranslation(-1024, 0);
        self.sceneMenu.transform = moveLeft;
    }];
    
    //look at the scene order dictionary in the Show object to place the scenes in the correct order
    [self.theShow.scenesOrder enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *sceneHash = (NSString *)obj;
        Scene *theScene = [self.theShow.scenes objectForKey:sceneHash];
        
        NSLog(@"%@",theScene);
        
        //do a bit of sanity check
        if (!theScene) NSLog(@"Cannot find scene with hash %@ in the plist file.\n", sceneHash);
        
        //create the button's frame
        CGRect frame;
        frame.origin.x = sceneMenu.frame.origin.x + idx * 230;
        frame.origin.y = 10;
        frame.size.width = 200;
        frame.size.height = 150;
        
        //create the actual button
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        
        //set tag number for each scene button to correspond with the scene order dict
        [button setTag:idx];
        [button setImage: theScene.coverPicture forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(selectScene:) forControlEvents:UIControlEventTouchUpInside];
        [sceneMenu addSubview:button];
        [button release];
    }];
    
    //set the content size of the scrollview and check to see if the scrollview is overflowing
    int extend = 0;    
    if (self.theShow.scenes.count > 4) extend = self.theShow.scenes.count - 4;
    
    [self.sceneMenu setContentSize:CGSizeMake(self.sceneMenu.frame.size.width + (extend * 200), 0)];
   
}

-(void)selectScene:(UIButton *)sender
{
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Loading..."];
    [self performSelectorInBackground:@selector(loadSceneEditViewController:) withObject:sender];
}

//need to do this because it takes some time to load the next controller. can display the loading spinner like that.
//-(void)loadSceneEditViewController:(UIButton *)sender
//{
//    //this method is run in a separate thread so need an autorelease pool specially for this
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    
//    //attempt to get the Scene from the Scenes dictionary for the key, which in turn is gotten from the scene order array
//    Scene *selectedScene = [self.theShow.scenes objectForKey:[self.theShow.scenesOrder objectAtIndex:sender.tag]];
//    
//    CoverScene *selectedCoverScene = [theCover coverSceneForSceneHash:selectedScene.hash];
//    
//    if (!selectedCoverScene)
//    {
//        //create a new CoverScene
//        selectedCoverScene = [NSEntityDescription insertNewObjectForEntityForName:@"CoverScene" inManagedObjectContext:managedObjectContext];
//        selectedCoverScene.SceneHash = selectedScene.hash;
//        [self.theCover addScenesObject:selectedCoverScene];
//        [self.context save:nil];
//    }
//    
//    SceneEditViewController *editController = [[SceneEditViewController alloc] initWithScene:selectedScene andSceneCover:selectedCoverScene andContext:context];
//    editController.title = selectedScene.title;
//    
//    [pool release];
//    
//    [self performSelectorOnMainThread:@selector(finishLoadingSceneEditViewController:) withObject:editController waitUntilDone:NO];
//}

-(void)finishLoadingSceneEditViewController:(SceneEditViewController *)theController
{
    [DSBezelActivityView removeViewAnimated:YES];
    [self.navigationController pushViewController:theController animated:YES];
    
    [theController release];
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

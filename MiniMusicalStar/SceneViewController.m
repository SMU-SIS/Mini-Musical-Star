//
//  Scene.m
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import "SceneViewController.h"


@implementation SceneViewController
@synthesize imageNum;
@synthesize theShow;
@synthesize chosenScene;
@synthesize theCover;
@synthesize context;
@synthesize saveCoverButton;
@synthesize userCoverName;
@synthesize coversList, coversPopover;

- (void)dealloc
{
    [saveCoverButton release];
    [coversList release];
    [coversPopover release];
    [context release];
    [showCover release];
    [sceneMenu release];
    [theShow release];
    [chosenScene release];
    [theCover release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(SceneViewController *)initWithScenesFromShow:(Show *)aShow andCover:(Cover *)aCover andContext:(NSManagedObjectContext *)aContext
{
    [super init];
    //store the current show as an ivar
    self.theShow = aShow;
    self.theCover = aCover;
    self.context = aContext;
    
    //load the cover list
    self.coversList = [[CoversListViewController alloc] init];
    self.coversList.delegate = self;
    self.coversPopover = [[UIPopoverController alloc] initWithContentViewController:coversList];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //load the covers
  
    //Settings for the scrollview
    [sceneMenu setScrollEnabled:YES];
    [sceneMenu setShowsHorizontalScrollIndicator:NO];
    [sceneMenu setShowsVerticalScrollIndicator:NO];
    [sceneMenu setPagingEnabled:NO]; 
    sceneMenu.clipsToBounds = NO;   
    
    //setting the Show's cover image at the yop of the scene
    showCover.image = theShow.coverPicture;
    
    
    //For the scene selection page. Scrollable.
    //get the scene images out of the show
    NSMutableArray *sceneImages = [[NSMutableArray alloc]initWithCapacity:theShow.scenes.count];
    [theShow.scenes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Scene *scene = (Scene *)obj;
        [sceneImages addObject:scene.coverPicture];
        
    }];
    
    [self displaySceneImages:sceneImages];

    //setting the content size of the scrollview
    int extend = 0;    
    if (sceneImages.count>4) {
        extend = sceneImages.count -4;
    }

    [sceneMenu setContentSize:CGSizeMake(sceneMenu.frame.size.width + (extend * 200), 0)];
}

- (NSArray *)coversForShow
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Cover" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    //predicate...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cover_of_showID == %i", theShow.showID];
    [request setPredicate:predicate];
    
    NSError *err = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&err];
    
    if (results == nil)
    {
        NSLog(@"Fetch error: %@", err);
    }
    
    NSLog(@"%i results found", results.count);
    
    return results;
    
}

- (void)viewWillAppear: (BOOL)animated
{
    [super viewWillAppear:animated];
    
    //disable the save cover button first
    self.saveCoverButton.enabled = NO;
    self.saveCoverButton.hidden = YES;
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"View Covers" style:UIBarButtonItemStylePlain target:self action:@selector(coversButtonPressed:)];          
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
    
    //if there are any edits, reflect them here
    if ([theCover showWasEdited])
    {
        self.title = [theShow.title stringByAppendingString:@" (edited)"];
        self.saveCoverButton.enabled = YES;
        self.saveCoverButton.hidden = NO;
    }
}

- (IBAction)saveCoverButtonPressed:(UIButton *)sender
{
    UIAlertView *saveModal = [[UIAlertView alloc] init];
    saveModal.delegate = self;
    saveModal.title = @"Name your creation!";
    saveModal.message = @" ";
    [saveModal addButtonWithTitle:@"Cancel"];
    [saveModal addButtonWithTitle:@"OK"];
    
    userCoverName = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
    userCoverName.backgroundColor = [UIColor whiteColor];
    
    [saveModal addSubview:userCoverName];
    [saveModal show];
    [saveModal release];
    [userCoverName release];
    
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        self.theCover.title = userCoverName.text;
        
        //save the cover to persistent storage
        [self.context save:nil];
        
        self.title = self.theCover.title;
    }
    
}

- (void)coversButtonPressed:(id)sender
{
    if (!self.coversPopover.isPopoverVisible)
    {
        [coversPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    else
    {
        [coversPopover dismissPopoverAnimated:YES];
    }

}

-(void)selectScene:(UIButton *)sender
{
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Loading..."];
    [self performSelectorInBackground:@selector(loadSceneEditViewController:) withObject:sender];
}

//need to do this because it takes some time to load the next controller. can display the loading spinner like that.
-(void)loadSceneEditViewController:(UIButton *)sender
{
    //this method is run in a separate thread so need an autorelease pool specially for this
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //attempt to get the Scene from the Cover
    Scene *selectedScene = [self.theShow.scenes objectAtIndex:sender.tag];
    
    __block CoverScene *selectedCoverScene = nil;
    [theCover.Scenes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        CoverScene *theCoverScene = (CoverScene *)obj;
        if ([theCoverScene.SceneNum intValue] == [selectedScene.sceneNumber intValue])
        {
            selectedCoverScene = theCoverScene;
            *stop = YES; 
            
        }
    }];
    
    if (selectedCoverScene == nil)
    {
        //then create a new one
        selectedCoverScene = [NSEntityDescription insertNewObjectForEntityForName:@"CoverScene" inManagedObjectContext:context];
        selectedCoverScene.SceneNum = [NSNumber numberWithInt:[selectedScene.sceneNumber intValue]];
        
        //[selectedCoverScene setSceneNum:[selectedScene sceneNumber]];
        [theCover addScenesObject:selectedCoverScene];
    }
    
    SceneEditViewController *editController = [[SceneEditViewController alloc] initWithScene:selectedScene andSceneCover:selectedCoverScene andContext:context];
    editController.title = selectedScene.title;
    
    [pool release];

    [self performSelectorOnMainThread:@selector(finishLoadingSceneEditViewController:) withObject:editController waitUntilDone:NO];
}

-(void)finishLoadingSceneEditViewController:(SceneEditViewController *)theController
{
    [DSBezelActivityView removeViewAnimated:YES];
    [self.navigationController pushViewController:theController animated:YES];
    
    //    editController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //    [self presentModalViewController:editController animated:YES];
    
    [theController release];
}


-(void)displaySceneImages:(NSArray *)images{
    for (int i=0; i<images.count; i++) {
        CGRect frame;
        frame.origin.x = sceneMenu.frame.origin.x + i * 230;
        frame.origin.y = 10;
        frame.size.width = 200;
        frame.size.height = 150;
        
        //NSLog(@"Width is %g", frame.size.width);
        //NSLog(@"Length is %g", frame.size.height);
        
        UIImage *img = [images objectAtIndex:i];
        
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        //set tag number for each scene button to correspond with the scenes array
        [button setTag:i];
        [button setImage:img forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(selectScene:) forControlEvents:UIControlEventTouchUpInside];
        [sceneMenu addSubview:button];
        [button release];
    }
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
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        return YES;
    }
    
    else
    {
        return NO;
    }
}



@end

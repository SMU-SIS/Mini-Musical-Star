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

- (void)dealloc
{
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
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  
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

- (void)viewWillAppear: (BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"View Covers" style:UIBarButtonItemStylePlain target:self action:@selector(testUIBarButton)];          
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
}

- (void)testUIBarButton
{
    UIAlertView *helloAlert = [[UIAlertView alloc] initWithTitle:@"Covers" message:@"Boo!" delegate:self cancelButtonTitle:@"Yeah ok, ok" otherButtonTitles:nil];
    [helloAlert show];
    [helloAlert release];
}


- (IBAction)backToMenu {
    [self dismissModalViewControllerAnimated:YES];    
}

- (void)setImageNum:(int)num 
{
    imageNum=num;
}

- (int) getImageNum
{
    return imageNum;
}

-(Scene *)returnCurrentSelectedScene
{
	// Calculate which page is visible 
	CGFloat pageWidth = sceneMenu.frame.size.width;
	int page = floor((sceneMenu.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    return [theShow.scenes objectAtIndex:0];
	//return [theShow.scenes objectAtIndex:page];
}

-(void)selectScene:(id)sender
{
    
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Loading..."];
    [self performSelectorInBackground:@selector(loadSceneEditViewController) withObject:nil];
}

//need to do this because it takes some time to load the next controller. can display the loading spinner like that.
-(void)loadSceneEditViewController
{
    //wei jie, I don't know how to get the value for selected scene so i hardcode first ok? help me change - Adrian
    
    //attempt to get the Scene from the Cover
    Scene *selectedScene = [self returnCurrentSelectedScene];
    
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
        NSLog(@"%@", selectedScene);
        selectedCoverScene.SceneNum = [NSNumber numberWithInt:[selectedScene.sceneNumber intValue]];
        
        //[selectedCoverScene setSceneNum:[selectedScene sceneNumber]];
        [theCover addScenesObject:selectedCoverScene];
    }
    
    SceneEditViewController *editController = [[SceneEditViewController alloc] initWithScene:selectedScene andSceneCover:selectedCoverScene andContext:context];
    editController.title = selectedScene.title;

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
        
        NSLog(@"Width is %g", frame.size.width);
        NSLog(@"Length is %g", frame.size.height);
        
        UIImage *img = [images objectAtIndex:i];
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        //set tag number for each scene button
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}



@end

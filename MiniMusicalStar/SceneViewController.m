//
//  Scene.m
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import "SceneViewController.h"
#import "Show.h"
#import "SceneEditViewController.h"
#import "Cover.h"
#import "CoverScene.h"
#import "DSActivityView.h"

@implementation SceneViewController
@synthesize theShow;
@synthesize theCover;
@synthesize context;
@synthesize sceneMenu;
@synthesize showCover;
@synthesize popoverController;
@synthesize exportButton;
@synthesize exportTableController;

- (void)dealloc
{
    [exportTableController release];
    [popoverController release];
    [exportButton release];
    [context release];
    [sceneMenu release];
    [theShow release];
    [theCover release];
    [showCover release];
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
    self = [super init];
    
    if (self)
    {
        //store the current show as an ivar
        self.theShow = aShow;
        self.theCover = aCover;
        self.context = aContext;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    exportButton = [[UIBarButtonItem alloc] initWithTitle:@"Export Musicals" style:UIBarButtonItemStylePlain target:self action:@selector(popoverExports:)];          
//    self.navigationItem.rightBarButtonItem = exportButton;
    
    //set the Show's cover image at the top of the scene
    showCover.image = theShow.coverPicture;
    
    [self loadSceneSelectionScrollView];
}

-(void) popoverExports: (id)sender{
    
    if ([popoverController isPopoverVisible]) {
        
        [popoverController dismissPopoverAnimated:YES];
        
    } else {
        
        exportTableController = [[ExportTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        exportTableController.theShow = theShow;
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:exportTableController];
        popoverController.popoverContentSize = CGSizeMake(400, 600);
        [popoverController presentPopoverFromBarButtonItem:exportButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        
    }
    
}

- (void)loadSceneSelectionScrollView
{
    self.sceneMenu.scrollEnabled = YES;
    self.sceneMenu.showsHorizontalScrollIndicator = NO;
    self.sceneMenu.showsVerticalScrollIndicator = NO;
    self.sceneMenu.pagingEnabled = NO;
    self.sceneMenu.clipsToBounds = NO;
    
    //look at the scene order dictionary in the Show object to place the scenes in the correct order
    [self.theShow.scenesOrder enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *sceneHash = (NSString *)obj;
        Scene *theScene = [self.theShow.scenes objectForKey:sceneHash];
        
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
-(void)loadSceneEditViewController:(UIButton *)sender
{
    //this method is run in a separate thread so need an autorelease pool specially for this
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //attempt to get the Scene from the Scenes dictionary for the key, which in turn is gotten from the scene order array
    Scene *selectedScene = [self.theShow.scenes objectForKey:[self.theShow.scenesOrder objectAtIndex:sender.tag]];
    
    CoverScene *selectedCoverScene = [theCover coverSceneForSceneHash:selectedScene.hash];
    
    if (!selectedCoverScene)
    {
        //create a new CoverScene
        selectedCoverScene = [NSEntityDescription insertNewObjectForEntityForName:@"CoverScene" inManagedObjectContext:context];
        selectedCoverScene.SceneHash = selectedScene.hash;
        [self.theCover addScenesObject:selectedCoverScene];
        [self.context save:nil];
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
    
    [theController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



@end

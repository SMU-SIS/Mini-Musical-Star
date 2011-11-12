//
//  ChoiceSelectionViewController.m
//  MiniMusicalStar
//
//  Created by Wei Jie Tan on 11/10/11.
//  Copyright 2011 weijie.tan.2009@gmail.com. All rights reserved.
//

#import "ChoiceSelectionViewController.h"
#import "DSActivityView.h"
#import "SceneStripController.h"
#import "MiniMusicalStarUtilities.h"

@implementation ChoiceSelectionViewController
@synthesize theShow;
@synthesize managedObjectContext;
@synthesize frc;
@synthesize showTitle, showDescription;
@synthesize exportTableController;
@synthesize mediaManagementButton;
@synthesize coverName;
@synthesize sceneStripController;
@synthesize coversTableView;
@synthesize currentSelectedCoversList;
@synthesize exportButton;
@synthesize exportViewController;
@synthesize grayViewButton;

- (void)dealloc
{
    [grayViewButton release];
    [exportViewController release];
    [exportButton release];
    [currentSelectedCoversList release];
    [coversTableView release];
    [sceneStripController release];
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
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"selection_background.png"]];
    [self.view setBackgroundColor:background];
    
    
    self.currentSelectedCoversList = [[CoversListViewController alloc] initWithShow:self.theShow context:self.managedObjectContext];
    self.currentSelectedCoversList.delegate = self;
    self.currentSelectedCoversList.view.frame = CGRectMake(625,160,400,608);
//    self.coversTableView = (UITableView* )self.currentSelectedCoversList.view;
    [self.currentSelectedCoversList.tableView setBackgroundColor:[UIColor clearColor]];
    self.currentSelectedCoversList.tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:self.currentSelectedCoversList.view];
    
    self.grayViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,1024,768)];
    grayViewButton.backgroundColor = [UIColor grayColor];
    grayViewButton.alpha = 0.0;
    [grayViewButton addTarget:self action:@selector(fadeGrayViewButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:grayViewButton];
    
    UIImageView *selectSceneHelpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taptoedit.png"]];
    selectSceneHelpImageView.frame = CGRectMake(0,583,500,125);
    [self.view addSubview:selectSceneHelpImageView];
    return self;
}

-(void) fadeGrayViewButton
{
    self.grayViewButton.alpha = 0.0;
    [self removeScrollStrip:nil];
}

- (IBAction)goToExportPage: (id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    Cover *aCover = [NSEntityDescription insertNewObjectForEntityForName:@"Cover" inManagedObjectContext:managedObjectContext];
    
    self.exportViewController = [[ExportViewController alloc] initWithNibName:@"ExportViewController" bundle:nil];
    self.exportViewController = [[ExportViewController alloc] initWithStuff:theShow :aCover context:self.managedObjectContext];
    [self.navigationController pushViewController:exportViewController animated:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

- (IBAction)promptForCoverName: (UIButton*)sender
{
    AlertPrompt *prompt = [AlertPrompt alloc];
	prompt = [prompt initWithTitle:@"Enter title for new Cover" message:@" " delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"Okay"];
//    [prompt setFrame:CGRectMake(412,600,200,150)];
	[prompt show];
	[prompt release];

}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        AlertPrompt *prompt = (AlertPrompt *)alertView;
        if (prompt.enteredText.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OOPS!" message:@"Please enter something!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
            [alert release]; 
        }
        else
        {
            Cover *newCover = [NSEntityDescription insertNewObjectForEntityForName:@"Cover" inManagedObjectContext:managedObjectContext];
            
            //set the attributes of the new cover object
            newCover.title = prompt.enteredText;
            newCover.originalHash = [MiniMusicalStarUtilities getUniqueFilenameWithoutExt];
            newCover.coverOfShowHash = theShow.showHash;
            [self loadSceneSelectionScrollViewWithCover:newCover];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    mediaManagementButton = [[UIBarButtonItem alloc] initWithTitle:@"Export Musicals" style:UIBarButtonItemStylePlain target:self action:@selector(showMediaManagement:)];          
//    self.navigationItem.rightBarButtonItem = mediaManagementButton;
    
    showCover.image = theShow.coverPicture;
    
    self.showTitle.text = self.theShow.title;
    self.showDescription.text = self.theShow.showDescription;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (IBAction)removeScrollStrip:(id) sender
{
    //just animate out
    if (self.sceneStripController.view.superview != nil)
    {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            CGAffineTransform moveRight = CGAffineTransformMakeTranslation(1024, 0);
            self.sceneStripController.view.transform = moveRight;
            
            [self.sceneStripController.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *subview = (UIView *)obj;
                subview.transform = moveRight;
            }];
            
        } completion:^(BOOL finished) {
            [self.sceneStripController.view removeFromSuperview];
            self.sceneStripController = nil;
        }];
    }
}

- (BOOL)bounceScrollStrip: (Cover*) aCover
{
    //just animate out
    if (self.sceneStripController.view.superview != nil)
    {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            CGAffineTransform moveRight = CGAffineTransformMakeTranslation(1024, 0);
            self.sceneStripController.view.transform = moveRight;
            
            [self.sceneStripController.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *subview = (UIView *)obj;
                subview.transform = moveRight;
            }];
            
        } completion:^(BOOL finished) {
            [self.sceneStripController.view removeFromSuperview];
            self.sceneStripController = nil;
            [self addScrollStrip:aCover];
        }];
        
        return YES;
    }
    return NO;
}

//called when adding a new cover, or selecting a cover from the list for the first time
- (void) addScrollStrip: (Cover*) aCover
{
    //create an instance of SceneStripController
    self.sceneStripController = [[SceneStripController alloc] initWithShow:self.theShow Cover:aCover];
    self.sceneStripController.delegate = self;
    [self.sceneStripController setCoverTitleLabel:aCover.title];
    sceneStripController.context = self.managedObjectContext;
    
    self.grayViewButton.opaque = NO;
    
    [self.view addSubview:self.sceneStripController.view];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
        CGAffineTransform moveLeft = CGAffineTransformMakeTranslation(-1024, 0);
        
        self.sceneStripController.view.transform = moveLeft;
        
        [self.sceneStripController.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *subview = (UIView *)obj;
            subview.transform = moveLeft;
        }];
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)loadSceneSelectionScrollViewWithCover:(Cover *)aCover
{
    if(self.sceneStripController.view.superview != nil){
        [self bounceScrollStrip:aCover];
        return;
    };
    
    [self addScrollStrip:aCover];
}

- (void)showActivitySpinner
{
    [DSBezelActivityView newActivityViewForView:self.view withLabel:@"Loading..."];
}


- (void)pushSceneEditViewController:(UIViewController *)aController
{
    [DSBezelActivityView removeViewAnimated:YES];
    [self.navigationController pushViewController:aController animated:YES];
}


-(IBAction) showMediaManagement: (id)sender{
    
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    Cover *aCover = [self.currentSelectedCoversList getSelectedCover:selectedIndexPath];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];

    
    self.exportViewController = [[ExportViewController alloc] initWithStuff:self.theShow :aCover context:managedObjectContext];
    
    [self.navigationController pushViewController:exportViewController animated:YES];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


@end

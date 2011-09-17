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

- (void)dealloc
{
    [super dealloc];
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
  
    //Settings for the scrollview
    [sceneMenu setScrollEnabled:YES];
    [sceneMenu setShowsHorizontalScrollIndicator:NO];
    [sceneMenu setShowsVerticalScrollIndicator:NO];
    [sceneMenu setPagingEnabled:NO]; 
    sceneMenu.clipsToBounds = NO;   
    
    //Codes to disply the picture of the musical above on the scene selection page
    menuImages = [ShowImage alloc];
    NSArray *images = [menuImages getShowImages];
    [menuImages autorelease];
    
    //setting the Show's cover image at the yop of the scene
    UIImage *img = [images objectAtIndex:imageNum];
    showCover.image = img;
    
    
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

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    
    [super viewWillAppear:animated];
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
    //wei jie, I don't know how to get the value for selected scene so i hardcode first ok? help me change - Adrian
//    NSLog(@"TMD : %@",theShow.scenes);
//    EditViewController *editScene = [[EditViewController alloc] initWithImagesFromScene:[theShow.scenes objectAtIndex:0]];
//    
//    
//    editScene.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentModalViewController:editScene animated:YES];
//    [editScene release];
    
    //wei jie, I don't know how to get the value for selected scene so i hardcode first ok? help me change - Adrian
    
    
    
    SceneEditViewController *editController = [[SceneEditViewController alloc] initWithScene:[self returnCurrentSelectedScene]];
    editController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:editController animated:YES];
    
    [editController release];
    
    
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

-(SceneViewController *)initWithScenesFromShow:(Show *)aShow
{
    [super init];
    //store the current show as an ivar
    self.theShow = aShow;
    
    return self;
}

@end

//
//  Scene.m
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import "SceneViewController.h"
#import "EditViewController.h"

@implementation SceneViewController
@synthesize imageNum;

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
    scenes = [ShowImage alloc];
    NSArray *sceneImages = [scenes getSceneImages:(imageNum)];
    [scenes autorelease];
    
    [self displaySceneImages:sceneImages];

    //setting the content size of the scrollview
    int extend = 0;    
    if (sceneImages.count>4) {
        extend = sceneImages.count -4;
    }

    [sceneMenu setContentSize:CGSizeMake(sceneMenu.frame.size.width + (extend * 200), 0)];
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

-(void)selectScene:(id)sender
{
    EditViewController *editScene = [[EditViewController alloc] initWithNibName:nil bundle:nil];
    
    editScene.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:editScene animated:YES];
    
    [editScene release];
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

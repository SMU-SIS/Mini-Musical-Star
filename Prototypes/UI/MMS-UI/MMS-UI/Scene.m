//
//  Scene.m
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import "Scene.h"
#import "Edit.h"

@implementation Scene
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
    //[sceneMenu  setZoomScale:1.5 animated:YES];   
    
    //Codes to disply the picture of the musical above on the scene selection page
    menuImages = [ShowImage alloc];
    NSArray *images = [menuImages getShowImages];
    [menuImages autorelease];
    
    
    UIImage *img = [images objectAtIndex:imageNum];
    [sceneButton setBackgroundImage:img forState:UIControlStateNormal];
    
    
    //For the scene selection page. Scrollable.
    scenes = [ShowImage alloc];
    NSArray *sceneImages = [scenes getSceneImages:(imageNum)];
    [scenes autorelease];
    
    for (int i=0; i<sceneImages.count; i++) {
        CGRect frame;
        frame.origin.x = sceneMenu.frame.origin.x + i * 230;
        frame.origin.y = 10;
        //frame.size = scrollView.frame.size;
        frame.size.width = 200;
        frame.size.height = 150;
        
        NSLog(@"Width is %g", frame.size.width);
        NSLog(@"Length is %g", frame.size.height);
        
        UIImage *img = [sceneImages objectAtIndex:i];
        
        //creating an ImageView and insert into scrollView as a subview
        /*
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = img;
        
        [sceneMenu addSubview:imageView];
        [imageView release];
         */
        
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setImage:img forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(selectScene:) forControlEvents:UIControlEventTouchUpInside];
        [sceneMenu addSubview:button];
        [button release];
        
    }
    
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

/*
-(IBAction)selectScene {
    Edit *editScene = [[Edit alloc] initWithNibName:nil bundle:nil];
    
    editScene.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:editScene animated:YES];
    
    [editScene release];
}
 */

-(void)selectScene:(id)sender
{
    Edit *editScene = [[Edit alloc] initWithNibName:nil bundle:nil];
    
    editScene.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:editScene animated:YES];
    
    [editScene release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //[imageView1 release];
    //[imageView2 release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end

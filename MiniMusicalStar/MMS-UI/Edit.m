//
//  Edit.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Edit.h"

@implementation Edit
@synthesize audioview, theShow, theScene;

- (Edit *)initWithShow:(Show *)aShow Scene:(Scene *)aScene
{
    [super init];
    self.theShow = aShow;
    self.theScene = aScene;
    
    return self;
}

- (void)dealloc
{
    [theShow release];
    [theScene release];
    [audioview release];
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
    leftView.image = [theScene randomScenePicture];
    audioview = [[FourthAttemptViewController alloc] init];
    [toggleView addSubview:[self graphicsView]];  
}

- (void)viewDidUnload
{
    [[self graphicsView] release];
    //[audioview release];
    [super viewDidUnload];
    [options release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

-(IBAction)setToggleOption
{
    //Decision for Segment Index == 0, which is the Graphics in the scene
    if (segControl.selectedSegmentIndex == 0) {

        [toggleView addSubview:[self graphicsView]];
        //[audioview release];
       /* 
        MixPlayerRecorder *mix = [MixPlayerRecorder alloc];
        [mix stop];
        [mix release];
        */
        //[[self graphicsView] release];
        //[audioview release];
        [audioview stopPlayer];
        [audioview.view removeFromSuperview];
    }
    else if (segControl.selectedSegmentIndex == 1) {
        //CGRect rect = CGRectMake(0, 0, toggleView.frame.size.width, toggleView.frame.size.height);
        
        //AudioMenu *audioMenu = [AudioMenu alloc];
        //UIView *newView = [audioMenu initWithFrame:rect];
        
        //[toggleView addSubview:newView];
        //[audioMenu release];  
        
        [toggleView addSubview:audioview.view];
        [self.graphicsView removeFromSuperview];
        
        //[audioview release];
        //[scrollView removeFromSuperview];
    }
    
}

-(IBAction)backToScene
{
    [self dismissModalViewControllerAnimated:YES];  
}

-(void)setImageToLeftView:(UIButton *)sender
{
    ShowImage *showImage = [ShowImage alloc];
    NSArray *images = [showImage getImagesInTheScene];
    
    UIButton *button = (UIButton *)sender;
    
    UIImage *img = [images objectAtIndex:button.tag];
    leftView.image = img;
    
    [self callGraphicsOption:button.tag];
}

-(UIView *)graphicsView
{
    CGRect rect = CGRectMake(0, 0, 480, 600);
    scrollView = [[UIScrollView alloc] initWithFrame:rect];
    
    //ShowImage *showImage = [ShowImage alloc];
    //NSArray *imagesInTheScene = [showImage getImagesInTheScene];
    
    NSMutableArray *imagesInTheScene = [[NSMutableArray alloc] initWithCapacity:theScene.pictureList.count];
    [theScene.pictureList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Picture *thePicture = (Picture *)obj;
        [imagesInTheScene addObject:[UIImage imageWithContentsOfFile:[thePicture relativePath]];
    }];
    
    BOOL odd = TRUE;
    
    for (int i = 0; i<imagesInTheScene.count; i++) {
        UIImage *img = [imagesInTheScene objectAtIndex:i];
        if (odd == TRUE) {
            CGRect left;
            left.origin.x=scrollView.frame.origin.x + 25;
            left.origin.y=scrollView.frame.origin.y + (i * 100) +25;	
            left.size.width = 200;
            left.size.height = 150;
            
            UIButton *button = [[UIButton alloc] initWithFrame:left];
            [button setImage:img forState:(UIControlStateNormal)];
            [button setTag:i];

            [button addTarget:self action:@selector(setImageToLeftView:) forControlEvents:UIControlEventTouchUpInside];
            
            odd = FALSE;
            
            [scrollView addSubview:button];
            [button release];
        }
        else {
            CGRect right;
            right.origin.x=scrollView.frame.origin.x + 255;
            right.origin.y=scrollView.frame.origin.y + ((i-1) * 100) +25;
            right.size.width = 200;
            right.size.height = 150;
            
            UIButton *button = [[UIButton alloc] initWithFrame:right];
            [button setImage:img forState:(UIControlStateNormal)];
            [button setTag:i];
            
            [button addTarget:self action:@selector(setImageToLeftView:) forControlEvents:UIControlEventTouchUpInside];            
            odd = TRUE; 
            
            [scrollView addSubview:button];
            [button release];
        }
        
    }
    [scrollView setContentSize:CGSizeMake(480, 600 + (imagesInTheScene.count-6)/2 * 175 + 100)];
    
    [scrollView setScrollEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setPagingEnabled:YES]; 
    scrollView.clipsToBounds = YES;
    //[scrollView setZoomScale:1.5 animated:YES];
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setScrollsToTop:NO];
    
    [showImage release];

    return [scrollView autorelease];

}

-(void)callGraphicsOption:(NSInteger)buttonNumber
{
    [options removeFromSuperview];
    NSInteger imageNum = buttonNumber +1;
    
    CGRect rect = CGRectMake(0, 0, 200, 250);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    
    CGRect rectLabel = CGRectMake(0, 0, 200, 20);
    UILabel *label = [[UILabel alloc] initWithFrame:rectLabel];
    label.text = @"Select Option";
    label.font = [UIFont fontWithName:@"Arial" size:14];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentCenter;
    
    CGRect rectButton = CGRectMake(0, 20, 200, 75);
    UIButton *button1 = [[UIButton alloc] initWithFrame:rectButton];
    [button1 setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    CGRect rectButton2 = CGRectMake(0, 95, 200, 75);
    UIButton *button2 = [[UIButton alloc] initWithFrame:rectButton2];
    [button2 setImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
    CGRect rectButton3 = CGRectMake(0, 170, 200, 75);
    UIButton *button3 = [[UIButton alloc] initWithFrame:rectButton3];
    [button3 setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(closeOptionMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    if (imageNum%2==0) {
        CGRect frame = CGRectMake(55, (buttonNumber-1)*100, 200, 250);
        options = [[UIView alloc] initWithFrame:frame];    
        imageView.image = [UIImage imageNamed:@"empty textbox right.png"];    
    }
    else {
        CGRect frame = CGRectMake(225, buttonNumber*100, 200, 250);
        options = [[UIView alloc] initWithFrame:frame];    
        imageView.image = [UIImage imageNamed:@"empty textbox.png"];
    }
    
    [options addSubview:imageView];
    [options addSubview:label];
    [options addSubview:button1];
    [options addSubview:button2];
    [options addSubview:button3];
    [scrollView addSubview:options];
    [imageView release];
    [label release];
    [button1 release];
    [button2 release];
    [button3 release];
    //[options release];    
}
-(void)closeOptionMenu:(id)sender
{
    [options removeFromSuperview];
}
@end

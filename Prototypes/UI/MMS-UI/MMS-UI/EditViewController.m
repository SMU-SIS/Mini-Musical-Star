//
//  Edit.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"

@implementation EditViewController

@synthesize chosenScene;
@synthesize audioview;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

- (void)dealloc
{
    
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
    
    leftView.image = [UIImage imageNamed:@"g1.png"];
    audioview = [[AudioViewController alloc] init];
    //VideoViewController *videoView = [VideoViewController alloc];
    [toggleView addSubview:[self graphicsView]]; 
    //[toggleView addSubview:videoView.view]; 
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

        //VideoViewController *videoView = [VideoViewController alloc];
        [toggleView addSubview:graphicsMenu];
        [audioview.view removeFromSuperview];
    }
    else if (segControl.selectedSegmentIndex == 1) {
        
        //VideoViewController *videoView = [VideoViewController alloc];
        [toggleView addSubview:audioview.view];
        [graphicsMenu removeFromSuperview];
    }
    
}

-(IBAction)backToScene
{
    [self dismissModalViewControllerAnimated:YES];  
}


-(void)setImageToLeftView:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    
    ShowImage *showImage = [ShowImage alloc];
    NSArray *images = [showImage getImagesInTheScene:chosenScene];
    
    
    
    UIImage *img = [images objectAtIndex:button.tag];
    leftView.image = img;
    
    [self callGraphicsOption:button.tag];
}

/*
-(void)setImageToLeftView:(UIImage *)img
{
    leftView.image = img;
}
*/

-(UIView *)graphicsView
{
    CGRect rect = CGRectMake(0, 0, 480, 600);
    scrollView = [[UIScrollView alloc] initWithFrame:rect];
    
    ShowImage *showImage = [ShowImage alloc];
    NSLog(@"closer nowwwww... %@", chosenScene);
    NSMutableArray *imagesInTheScene = [showImage getImagesInTheScene:chosenScene];
    NSLog(@"HELO!");
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
        [scrollView setContentOffset:(CGPointMake(0, (buttonNumber-1)*100)) animated:YES];        options = [[UIView alloc] initWithFrame:frame];    
        imageView.image = [UIImage imageNamed:@"empty textbox right.png"];
    }
    else {
        CGRect frame = CGRectMake(225, buttonNumber*100, 200, 250);
        [scrollView setContentOffset:(CGPointMake(0, buttonNumber*100)) animated:YES];
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

-(EditViewController *)initWithImagesFromScene:(Scene *)aScene
{
    [super init];
    //store the current show as an ivar
    self.chosenScene = aScene;
    NSLog(@"lalalala %@", self.chosenScene);
    
    return self;
}

@end

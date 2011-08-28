//
//  Edit.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Edit.h"
#import "Scene.h"


@implementation Edit


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
    audioview = [[FourthAttemptViewController alloc] init];
    [toggleView addSubview:[self graphicsView]];  
}

- (void)viewDidUnload
{
    [[self graphicsView] release];
    //[audioview release];
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

-(void)setImageToLeftView:(id)sender
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
    
    ShowImage *showImage = [ShowImage alloc];
    NSArray *imagesInTheScene = [showImage getImagesInTheScene];
    
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
    NSInteger imageNum = buttonNumber +1;
    
    if (imageNum%2 == 0) {
        [imageView removeFromSuperview];
        
        CGRect frame = CGRectMake(55, (buttonNumber-1)*100, 200, 250);
        
        imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [UIImage imageNamed:@"gfxoption.png"];
        
        imageView.transform = CGAffineTransformMakeScale(-1, 1);
        
        
        [scrollView addSubview:imageView];
        [imageView release];
    }
    else
    {
        [imageView removeFromSuperview];
        
        CGRect frame = CGRectMake(225, buttonNumber*100, 200, 250);
        
        imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [UIImage imageNamed:@"gfxoption.png"];
        
        [scrollView addSubview:imageView];
        [imageView release];
    }
    
    
    
    
}


@end

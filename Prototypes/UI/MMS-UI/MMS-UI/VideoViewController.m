//
//  VideoViewController.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"


@implementation VideoViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    CGRect rect = CGRectMake(0, 0, 480, 600);
    scrollView = [[UIScrollView alloc] initWithFrame:rect];

    ShowImage *showImage = [ShowImage alloc];
    NSArray *imagesInTheScene = [showImage getImagesInTheScene];
    
    [self positionTheImages:imagesInTheScene];
    
    [scrollView setContentSize:CGSizeMake(480, 600 + (imagesInTheScene.count-6)/2 * 175 + 100)];
    
    [scrollView setScrollEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setPagingEnabled:YES]; 
    scrollView.clipsToBounds = YES;
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setScrollsToTop:NO];
    
    [showImage release];    
}


-(void)positionTheImages:(NSArray *)images
{
    BOOL odd = TRUE;
    
    for (int i = 0; i<images.count; i++) {
        NSLog(@"Button numer %i", i);
        UIImage *img = [images objectAtIndex:i];
        if (odd == TRUE) {
            NSLog(@"Button numer %@", img);
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
}


-(void)setImageToLeftView:(UIButton *)sender
{
    //UIButton *button = (UIButton *)sender;
    
    //ShowImage *showImage = [ShowImage alloc];
    //NSArray *images = [showImage getImagesInTheScene];    
    
    //UIImage *img = [images objectAtIndex:button.tag];
    
    //EditViewController *editing = [EditViewController alloc];
    //[editing setImageToLeftView:img];
    
    //[showImage release];
    //[editing release];
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



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end

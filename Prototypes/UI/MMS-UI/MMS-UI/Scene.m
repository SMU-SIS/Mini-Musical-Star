//
//  Scene.m
//  MMS-UI
//
//  Created by Asti Andayani Temi on 11/8/11.
//  Copyright 2011 Singapore Management University. All rights reserved.
//

#import "Scene.h"

@implementation Scene
@synthesize imageNum;

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
    
    menuImages = [ShowImage alloc];
    NSArray *images = [menuImages getShowImages];
    [menuImages autorelease];
    
    
    UIImage *img = [images objectAtIndex:imageNum];
    
    [imageView setImage:img];
    // Do any additional setup after loading the view from its nib.
    
    //[self setToggleMenu];
    
    CGRect rect1 = CGRectMake(0, 0, toggleview.frame.size.width, toggleview.frame.size.height);
    imageView1 = [[UIImageView alloc] initWithFrame:rect1];
    imageView1.image = [UIImage imageNamed:@"glee1.jpg"];
    [toggleview addSubview:imageView1];
    [imageView1 release];

    

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

-(IBAction)setToggleMenu
{
    //int selection;
	//election = segControl.selectedSegmentIndex;
    
    if (segControl.selectedSegmentIndex == 0) {
        CGRect rect2 = CGRectMake(0, 0, toggleview.frame.size.width, toggleview.frame.size.height);
        
        imageView2 = [[UIImageView alloc] initWithFrame:rect2];
        imageView2.image = [UIImage imageNamed:@"glee1.jpg"];
        [toggleview addSubview:imageView2];
        [imageView2 release];        
    }
    else if (segControl.selectedSegmentIndex == 1) {
        CGRect rect1 = CGRectMake(0, 0, toggleview.frame.size.width, toggleview.frame.size.height);
        imageView1 = [[UIImageView alloc] initWithFrame:rect1];
        imageView1.image = [UIImage imageNamed:@"glee2.jpg"];
        [toggleview addSubview:imageView1];
        [imageView1 release];    
    }

}

@end

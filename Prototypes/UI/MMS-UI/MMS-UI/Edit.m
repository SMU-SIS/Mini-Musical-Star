//
//  Edit.m
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "Edit.h"
@implementation Edit
@synthesize imageView1, imageView2, sampleview;


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
    sampleview = [[A_sampleViewController alloc] init];
    //[self setToggleMenu];    
    CGRect rect1 = CGRectMake(0, 0, toggleView.frame.size.width, toggleView.frame.size.height);
    
    imageView1 = [[UIImageView alloc] initWithFrame:rect1];
    imageView1.image = [UIImage imageNamed:@"glee1.jpg"];
    [toggleView addSubview:imageView1];
    [imageView1 release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [sampleview release];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

-(IBAction)setToggleOption
{
    //int selection;
	//election = segControl.selectedSegmentIndex;
    
    if (segControl.selectedSegmentIndex == 0) {
        CGRect rect2 = CGRectMake(0, 0, toggleView.frame.size.width, toggleView.frame.size.height);
        
        imageView2 = [[UIImageView alloc] initWithFrame:rect2];
        imageView2.image = [UIImage imageNamed:@"glee1.jpg"];
        [toggleView addSubview:imageView2];
        [imageView2 release];
        [sampleview.view removeFromSuperview];
    }
    else if (segControl.selectedSegmentIndex == 1) {
        CGRect rect1 = CGRectMake(0, 0, toggleView.frame.size.width, toggleView.frame.size.height);
               
        [toggleView addSubview:sampleview.view];
        //[helloview release];
        //imageView1 = [[UIImageView alloc] initWithFrame:rect1];
        //imageView1.image = [UIImage imageNamed:@"glee2.jpg"];
        //[toggleView addSubview:imageView1];
        //[imageView1 release];    
    }
    
}

-(IBAction)backToScene
{
    [self dismissModalViewControllerAnimated:YES];  
}

/*
-(IBAction)backtoMenu
{
    //[self dismissModalViewControllerAnimated:YES]; 
    Scene *scene = [[Scene alloc] initWithNibName:nil bundle:nil];
    
    [scene fromEditToMenu];
    [scene release];
}
 */

@end

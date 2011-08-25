//
//  PickThePhoto2ViewController.m
//  PickThePhoto2
//
//  Created by Tommi on 25/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PickThePhoto2ViewController.h"

@implementation PickThePhoto2ViewController

@synthesize imagesArray;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init the array with images
    imagesArray = [[NSMutableArray arrayWithObjects:[UIImage imageNamed:@"glee1.jpg"], [UIImage imageNamed:@"glee2.jpg"], [UIImage imageNamed:@"glee3.jpg"], nil] retain];

    
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

- (IBAction)callModal {
    NSLog(@"test");
}

@end

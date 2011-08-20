//
//  ChangeThePhotoViewController.m
//  ChangeThePhoto
//
//  Created by Tommi on 19/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChangeThePhotoViewController.h"

@implementation ChangeThePhotoViewController
@synthesize imageView, imagesArray;

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
    
    [imageView setImage:[imagesArray objectAtIndex:0]];
    
    [self replaceImage:0];
    [self refreshImageView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [imagesArray release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void) replaceImage: (NSInteger*) imageIndex {
    UIImage *newImage = [UIImage imageNamed:@"glee3.jpg"];
    
    [imagesArray replaceObjectAtIndex:0 withObject:newImage];
}

-(void) refreshImageView {
    [imageView setImage:[imagesArray objectAtIndex:0]];
}



@end

//
//  SlideShowAppViewController.m
//  SlideShowApp
//
//  Created by Tommi on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SlideShowAppViewController.h"

@implementation SlideShowAppViewController

@synthesize imageView;
@synthesize nextButton;

- (void)dealloc
{
    [nextButton release];
    [imageView release];
    [super dealloc];
}

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
    
    imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"glee1.jpg"], [UIImage imageNamed:@"glee2.jpg"], [UIImage imageNamed:@"glee3.jpg"], nil]; //load an array of UIImages
    
    //probably need another way to load these images, eg. read the uploaded data structure for file names.
    
    [imagesArray retain]; //If I don't do this, the array will be released at the end of this method. Just remember to release it at viewDidUnload
    
    imagesArraySize = [imagesArray count]; //store size of imagesArray
    
    imgCounter = 0; //tracking counter, by index

    [imageView setImage:[imagesArray objectAtIndex:0]]; //set the 1st image
    
    //[image1 release]; //release the image now that we have a UIImageView that contains it.
    
    [nextButton addTarget:self action:@selector(myButtonPressed:) forControlEvents:(UIControlEvents)UIControlEventTouchDown]; //register the TouchDown event to the myButtonPressed method
    
}

/* Method to handle the button pressed. */

- (IBAction)myButtonPressed:(id)sender {
    
    imgCounter++;
    
    if (imgCounter >= imagesArraySize) {
        imgCounter = 0;
    }
    
    [imageView setImage:[imagesArray objectAtIndex:imgCounter]]; //set the 1st image

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.imageView = nil;
    self.nextButton = nil;
    
    [imagesArray release];
    [imageView release];
    [nextButton release];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end

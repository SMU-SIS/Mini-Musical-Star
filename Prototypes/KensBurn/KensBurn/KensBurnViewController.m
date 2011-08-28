//
//  KensBurnViewController.m
//  KensBurn
//
//  Created by Tommi on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KensBurnViewController.h"

@implementation KensBurnViewController

@synthesize imageView, startStopButton;

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
    
    UIImage* anImage = [UIImage imageNamed:@"glee1.jpg"];
    [imageView setImage:anImage];

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

- (IBAction)startStopButtonClicked
{
    [self startKensBurn];
}

- (void)startKensBurn
{
    [UIView animateWithDuration:8 animations:^(void) {
        CGAffineTransform zoomIn = CGAffineTransformMakeScale(1.9, 1.9);
        CGAffineTransform moveRight = CGAffineTransformMakeTranslation(-200, 0);
        CGAffineTransform combo1 = CGAffineTransformConcat(zoomIn, moveRight);
        imageView.transform = combo1;
    }];
    
    /* FOR REFERENCE
     [UIView animateWithDuration:8 animations:^(void) {
     CGAffineTransform zoomIn = CGAffineTransformMakeScale(1.9, 1.9);
     CGAffineTransform moveRight = CGAffineTransformMakeTranslation(-200, 0);
     CGAffineTransform combo1 = CGAffineTransformConcat(zoomIn, moveRight);
     imageView.transform = combo1;
     }
     completion:^(BOOL finished) {
     [UIView animateWithDuration:7 animations:^(void) {
     CGAffineTransform moveRight = CGAffineTransformTranslate(imageView.transform, -200, 0);
     imageView.transform = moveRight;
     }];
     }];
     */
    
    
}

@end

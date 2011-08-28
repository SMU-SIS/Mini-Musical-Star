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
    
    //set the default value
    isKensBurning = NO;
    
    UIImage* anImage = [UIImage imageNamed:@"glee2.jpg"];
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
    if (isKensBurning == NO)
    {
        [self startKensBurn];
    }
    else
    {
        [self stopKensBurn];
    }
}

- (void)startKensBurn
{
//    [UIView beginAnimations:@"panning" context:NULL];
//    [UIView setAnimationDelegate:self];
//	[UIView setAnimationDuration:5];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn]; //what is this
//    
//    CGAffineTransform rotate = CGAffineTransformMakeRotation(0.95);
//	//CGAffineTransform moveRight = CGAffineTransformMakeTranslation(100, 200);
//	CGAffineTransform moveRight = CGAffineTransformMakeTranslation(100, 0);
//    CGAffineTransform combo1 = CGAffineTransformConcat(rotate, moveRight);
//	CGAffineTransform zoomIn = CGAffineTransformMakeScale(5.8, 5.8);
//	CGAffineTransform transform = CGAffineTransformConcat(zoomIn, combo1);
//    
//    
//    imageView.transform = moveRight;
//	[UIView commitAnimations];
    
    [self startKensZooming];
    
}

- (void)startKensZooming
{
    [UIView beginAnimations:@"zoomin" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:5];
    
    CGAffineTransform zoomIn = CGAffineTransformMakeScale(5.8, 5.8);
    
    imageView.transform = zoomIn;
	
    [UIView commitAnimations];
}

- (void)startKensBurnPanning
{
    [UIView beginAnimations:@"panning" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:5];
    
    CGAffineTransform moveRight = CGAffineTransformMakeTranslation(200, 0);
    
    imageView.transform = moveRight;
	
    [UIView commitAnimations];

}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:@"zoomin"])
    {
        NSLog(@"zooming has ended");
        
        [self startKensBurnPanning];
    }
    else if ([animationID isEqualToString:@"panning"])
    {
        NSLog(@"panning has ended");
    }
}

@end

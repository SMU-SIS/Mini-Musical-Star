//
//  CoverFlowViewController.m
//  MMS-UI
//
//  Created by Adrian on 15/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoverFlowViewController.h"

@implementation CoverFlowViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// loading images into the queue
	
	loadImagesOperationQueue = [[NSOperationQueue alloc] init];
	
	
	NSString *imageName;
	for (int i=0; i < 10; i++) {
		imageName = [[NSString alloc] initWithFormat:@"g%d.jpg", i];
		[(AFOpenFlowView *)self.view setImage:[UIImage imageNamed:imageName] forIndex:i];
		[imageName release];
		NSLog(@"%d is the index",i);
		
	}
	[(AFOpenFlowView *)self.view setNumberOfImages:10];
	
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index{
	
	
	NSLog(@"%d is selected",index);
	
}
- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index{
}


- (UIImage *)defaultImage{
	
	return [UIImage imageNamed:@"glee_1.jpg"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end

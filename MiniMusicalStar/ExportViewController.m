//
//  ExportViewController.m
//  MiniMusicalStar
//
//  Created by Tommi on 30/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ExportViewController.h"

@implementation ExportViewController

@synthesize theShow, theCover, context;
@synthesize background;
@synthesize exportContainerView;
@synthesize uploadContainerView;
    
- (ExportViewController*)initWithStuff:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext;
{
    self = [super init];
    if (self) {
        self.theShow = show;
        self.theCover = cover;
        self.context = aContext;
    }
    
    return self;
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
    self.background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"exportpage.png"]];
    self.view.backgroundColor = background;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc
{
    [super dealloc];
    [background release];
    [exportContainerView release];
    [uploadContainerView release];
}

@end

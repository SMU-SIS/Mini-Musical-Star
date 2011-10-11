//
//  NewOpenViewController.m
//  MiniMusicalStar
//
//  Created by Jun Kit Lee on 11/10/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "NewOpenViewController.h"

#import "Show.h"

@implementation NewOpenViewController
@synthesize theShow, context;

-(void)dealloc
{
    [theShow release];
    [context release];
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithShow:(Show *)aShow context:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self)
    {
        self.theShow = aShow;
        self.context = aContext;
        
        self.title = self.theShow.title;
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
    // Do any additional setup after loading the view from its nib.
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

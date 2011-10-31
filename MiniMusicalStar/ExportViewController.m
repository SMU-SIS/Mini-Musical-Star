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
@synthesize exportTableViewController;
@synthesize mediaTableViewController;
    
- (ExportViewController*)initWithStuff:(Show*)show:(Cover*)cover context:(NSManagedObjectContext *)aContext;
{
    self = [super init];
    if (self) {
        self.theShow = show;
        self.theCover = cover;
        self.context = aContext;
        
        self.exportTableViewController = [[ExportTableViewController alloc] initWithStyle:UITableViewStyleGrouped :theShow :theCover context:context];
        self.mediaTableViewController = [[MediaTableViewController alloc] initWithStyle:UITableViewStylePlain];
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

    self.exportTableViewController.tableView.backgroundView.alpha = 0.0;
    CGRect frame = self.exportTableViewController.tableView.frame;
    frame.size.width = 450;
    frame.size.height = 450;
    exportTableViewController.tableView.frame = frame;
    [self.exportContainerView addSubview:exportTableViewController.tableView];
    [self.exportContainerView release]; //exportContainerView is incharge of releasing it
    [self.view addSubview:self.mediaTableViewController.view];

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
    [mediaTableViewController release];
    [exportTableViewController release];
    [background release];
    [exportContainerView release];
    [uploadContainerView release];
}

@end

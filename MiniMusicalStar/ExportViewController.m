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
        self.mediaTableViewController = [[MediaTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        self.background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"exportpage.png"]];
        self.view.backgroundColor = background;
        
//        self.exportTableViewController.tableView.backgroundView.alpha = 0;
        self.exportTableViewController.tableView.frame = CGRectMake(50,200,400,450);
        
        self.mediaTableViewController.tableView.frame = CGRectMake(570,200,370,480);
//        self.mediaTableViewController.tableView.backgroundView.alpha = 0;
        
        [self.view addSubview:self.exportTableViewController.tableView];
        [self.view addSubview:self.mediaTableViewController.tableView];
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
}

@end

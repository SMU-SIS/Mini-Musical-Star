//
//  PhotoEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoEditorViewController.h"

@implementation PhotoEditorViewController

@synthesize leftPicture, rightPicture, centerPicture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [self setSliderImages: 15];
}

- (void) setSliderImages:(UInt32)timeAt
{
    Show *show = [[ShowDAO shows] objectAtIndex:0];
    NSMutableArray *pictureList = [[[show scenes] objectAtIndex:0] pictureList];
//    NSArray *slideShowPictureList = [[NSArray alloc] init];
    
    [pictureList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Picture *pic = (Picture*)obj;
        UInt32 startTime = pic.startTime;
//        NSLog(@"startTime123: %lu ", pic.startTime);
        UInt32 endTime = pic.startTime + pic.duration;
//        UInt32 endTime = 20;
        if(startTime <= timeAt && endTime >= timeAt){
            centerPicture.image = pic.image;
            NSLog(@"startTime: %lu ",startTime);
            NSLog(@"endTime: %lu",endTime);
        }
        
    }];
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

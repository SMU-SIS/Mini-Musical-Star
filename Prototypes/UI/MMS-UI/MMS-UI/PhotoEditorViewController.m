//
//  PhotoEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoEditorViewController.h"

@implementation PhotoEditorViewController

@synthesize leftPicture, rightPicture, centerPicture, thePictures;

-(void)dealloc
{
    [leftPicture release];
    [rightPicture release];
    [centerPicture release];
    [thePictures release];
    [super dealloc];
}

- (PhotoEditorViewController *)initWithPhotos:(NSArray *)pictureArray
{
    self = [super init];
    if (self)
    {
        self.thePictures = pictureArray;
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
    [self setSliderImages: 0];
}

- (void) setSliderImages:(UInt32)timeAt
{
    __block UInt32 centerOrderNumber;
    [thePictures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Picture *pic = (Picture*)obj;
        UInt32 startTime = pic.startTime;
        UInt32 endTime = pic.startTime + pic.duration;
        if(startTime <= timeAt && endTime > timeAt){
            centerPicture.image = pic.image;
//            NSLog(@"startTime: %lu ",startTime);
//            NSLog(@"endTime: %lu",endTime);
            centerOrderNumber = pic.orderNumber;
        }
        
        
    }];

    [thePictures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Picture *pic = (Picture*)obj;
        UInt32 leftOrderNumber = centerOrderNumber - 1;
        UInt32 rightOrderNumber = centerOrderNumber + 1;
        
        if(leftOrderNumber == 0){
            leftPicture.image = nil;
        }
        if(pic.orderNumber == leftOrderNumber){
            leftPicture.image = pic.image;
        }
        
        if(pic.orderNumber == rightOrderNumber){
            rightPicture.image = pic.image;
        }
        
        if(rightOrderNumber == [thePictures count] + 1){
            rightPicture.image = nil;
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

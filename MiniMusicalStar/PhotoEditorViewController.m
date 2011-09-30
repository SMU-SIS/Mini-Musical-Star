//
//  PhotoEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoEditorViewController.h"

@implementation PhotoEditorViewController

@synthesize leftPicture, rightPicture, centerPicture, thePictures, imagesArray, theCoverScene, context, currentSelectedCover, cameraPopupViewController, delegate;

-(void)dealloc
{
    [leftPicture release];
    [rightPicture release];
    [centerPicture release];
    [thePictures release];
    [imagesArray release];
    [theCoverScene release];
    [context release];
    [cameraPopupViewController release];
    [super dealloc];
}


- (PhotoEditorViewController *)initWithPhotos:(NSArray *)pictureArray andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self)
    {
        self.thePictures = pictureArray;
        self.theCoverScene = aCoverScene;
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
    ((AFOpenFlowView *)self.view).viewDelegate = self;
    [self performSelector:@selector(loadImagesIntoOpenFlow)];
    
}

- (void) loadImagesIntoOpenFlow
{
    loadImagesOperationQueue = [[NSOperationQueue alloc] init];
    
    __block int count= 0;
    [thePictures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Picture *pic = (Picture*)obj;
        CoverScenePicture *coverPicture = [theCoverScene pictureForOrderNumber:count];
//        NSLog(@"coverPictures: %@",coverPicture);
        if (coverPicture == nil)
        {
            [(AFOpenFlowView *)self.view setImage: pic.image forIndex: count];
        }
        
        else
        {
            [(AFOpenFlowView *)self.view setImage: [coverPicture image] forIndex: count];
        }
        count = count + 1;
        
    }];
    
	[(AFOpenFlowView *)self.view setNumberOfImages:[thePictures count]];
    [self setSliderImages: 0];
}

- (BOOL) setSliderImages:(UInt32)timeAt
{
    __block BOOL success = FALSE;
    [thePictures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Picture *pic = (Picture*)obj;
        UInt32 startTime = pic.startTime;
        UInt32 endTime = pic.startTime + pic.duration;
        if(startTime <= timeAt && endTime > timeAt){
            centerPicture.image = pic.image;
            [(AFOpenFlowView *)self.view setSelectedCover:(pic.orderNumber - 1)];
            [(AFOpenFlowView *)self.view centerOnSelectedCover:true];
            success = TRUE;
        }
        
    }];
    return success;

    
}

- (int)replaceCenterImage: (UIImage*)image
{
    [(AFOpenFlowView *)self.view setImage:image forIndex:self.currentSelectedCover];
    return self.currentSelectedCover;
}


- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index
{    
	self.currentSelectedCover = index;
    Picture *pic = [thePictures objectAtIndex:index]; 
    [self.delegate setSliderPosition: pic.startTime];
    
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index
{
    //empty for now
}

//for the AFCoverFlow delegate
- (UIImage *)defaultImage
{
    return nil;
}

- (IBAction) popupCameraOptions: (id) sender
{
    if(![self.delegate isRecording]){
        CameraPopupViewController *overlayView = [[CameraPopupViewController alloc] initWithCoverScene:theCoverScene andContext:context];
        
        [overlayView.view setAlpha:0.0];
        [self.view addSubview:overlayView.view];
        [UIView beginAnimations:nil context:nil];
        [overlayView.view setAlpha:1.0];
        [UIView commitAnimations];
        
        [delegate stopPlayer];
        
        [overlayView setDelegate:self];
    }

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

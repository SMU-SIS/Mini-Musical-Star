//
//  PhotoEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoEditorViewController.h"

@implementation PhotoEditorViewController

@synthesize leftPicture, rightPicture, centerPicture, thePictures, imagesArray, theCoverScene, context, btn, currentSelectedCover, cameraPopupViewController;

-(void)dealloc
{
    [leftPicture release];
    [rightPicture release];
    [centerPicture release];
    [thePictures release];
    [imagesArray release];
    [theCoverScene release];
    [context release];
    [btn release];
    [cameraPopupViewController release];
    [super dealloc];
}

- (void) takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        self.view.hidden = YES;
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;

        imagePicker.allowsEditing = NO;
        
                UIPopoverController *popoverController = [[UIPopoverController alloc]
                                          initWithContentViewController:imagePicker];
                
//                popoverController.delegate = self;
        
        
                [popoverController 
                 presentPopoverFromRect: CGRectMake(0, 0, 500, 500) 
                 inView:self.view 
                 permittedArrowDirections:UIPopoverArrowDirectionDown 
                 animated:YES]; 
//        [self presentModalViewController:imagePicker
//                                animated:YES];
        [imagePicker release];
    }
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
    
    [thePictures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Picture *pic = (Picture*)obj;
        CoverScenePicture *coverPicture = [theCoverScene pictureForOrderNumber:pic.orderNumber];
        
        if (coverPicture == nil)
        {
            [(AFOpenFlowView *)self.view setImage: pic.image forIndex: idx];
        }
        
        else
        {
            [(AFOpenFlowView *)self.view setImage: [coverPicture image] forIndex: idx];
        }
        
    }];
    
	[(AFOpenFlowView *)self.view setNumberOfImages:[thePictures count]];
    [self setSliderImages: 0];
}

- (void) setSliderImages:(UInt32)timeAt
{
    [thePictures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Picture *pic = (Picture*)obj;
        UInt32 startTime = pic.startTime;
        UInt32 endTime = pic.startTime + pic.duration;
        if(startTime <= timeAt && endTime > timeAt){
            centerPicture.image = pic.image;
            [(AFOpenFlowView *)self.view setSelectedCover:pic.orderNumber - 1];
            [(AFOpenFlowView *)self.view centerOnSelectedCover:true];
        }
        
    }];

    
}


- (IBAction) replaceImageTest:(UIButton *)sender
{
    NSLog(@"Replacing first photo in the set with something new...");
    CoverScenePicture *newPicture = [NSEntityDescription insertNewObjectForEntityForName:@"CoverScenePicture" inManagedObjectContext:context];
    newPicture.OrderNumber = [NSNumber numberWithInt:1];
    newPicture.Path = [[NSBundle mainBundle] pathForResource:@"hsmS3" ofType:@"jpeg"];
    
    [self.theCoverScene addPictureObject:newPicture];
    [(AFOpenFlowView *)self.view setImage: [newPicture image] forIndex:self.currentSelectedCover];
}

- (void)replaceCenterImage: (UIImage*)image
{
    
    [(AFOpenFlowView *)self.view setImage:image forIndex:self.currentSelectedCover];
}


//delegate protocols

// delegate protocol to tell which image is selected
- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index
{    
	self.currentSelectedCover = index;
}


//for the AFCoverFlow delegate
- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index
{
    
}

- (IBAction) popupCameraOptions: (id) sender
{
    
    CameraPopupViewController *overlayView = [[CameraPopupViewController alloc] init];
    
    [overlayView.view setAlpha:0.0];
    [self.view addSubview:overlayView.view];
    [UIView beginAnimations:nil context:nil];
    [overlayView.view setAlpha:1.0];
    [UIView commitAnimations];

    [overlayView setDelegate:self];

}


//for the AFCoverFlow delegate
- (UIImage *)defaultImage
{
    return [(AFOpenFlowView *)self.view requestImageForIndex:0];
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

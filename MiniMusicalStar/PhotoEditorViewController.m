//
//  PhotoEditorViewController.m
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoEditorViewController.h"

@implementation PhotoEditorViewController

@synthesize leftPicture, rightPicture, centerPicture, theScene, imagesArray, theCoverScene, context, currentSelectedCover, cameraPopupViewController, delegate, exportFilename, tutorialButton;

-(void)dealloc
{
    [tutorialButton release];
    [exportFilename release];
    [leftPicture release];
    [rightPicture release];
    [centerPicture release];
    [theScene release];
    [imagesArray release];
    [theCoverScene release];
    [context release];
    [cameraPopupViewController release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (id)initWithScene:(Scene *)aScene andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)aContext
{
    self = [super init];
    if (self)
    {
        self.theScene = aScene;
        self.theCoverScene = aCoverScene;
        self.context = aContext;
        self.imagesArray = [[NSMutableArray alloc]init];
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
    
//    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"softboard" ofType:@"png"]]];
//    [self.view setBackgroundColor:background];
    
    //Applying autosave here
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autosaveWhenContextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
    
}

-(void)autosaveWhenContextDidChange:(NSNotification*)notification
{
    NSError *thisError;
    [context save:&thisError];
}

- (void) loadImagesIntoOpenFlow
{
    loadImagesOperationQueue = [[NSOperationQueue alloc] init];
    
    int seconds = 0;
    int processedImages = 0;
    int numberOfImages = [theScene.pictureDict count];
    
    while (processedImages < numberOfImages)
    {
        Picture *thePicture = [theScene pictureForAbsoluteSecond:seconds];
        if (thePicture)
        {
            //check if there is a cover picture
            NSString *hash = thePicture.hash;
            CoverScenePicture *coverPicture = [theCoverScene pictureForOriginalHash:hash];
            
            if (coverPicture)
            {
                [(AFOpenFlowView *)self.view setImage: [coverPicture image] forIndex: processedImages];
                [self.imagesArray addObject:[coverPicture image]];
            }
            
            else
            {
                [(AFOpenFlowView *)self.view setImage: thePicture.image forIndex: processedImages];
                [self.imagesArray addObject:thePicture.image];

            }
            
            processedImages++;
        }
        
        seconds++;
    }
    
	[(AFOpenFlowView *)self.view setNumberOfImages:numberOfImages];
    if (numberOfImages > 0) [self setSliderImages: 0];
}

- (BOOL) setSliderImages:(UInt32)timeAt
{
    if (imagesArray.count > 0)
    {
        [(AFOpenFlowView *)self.view setSelectedCover:[theScene pictureNumberToShowForSeconds:timeAt]];
        [(AFOpenFlowView *)self.view centerOnSelectedCover:true];
    }

    
    return YES;
    
}

- (int)replaceCenterImage: (UIImage*)image
{
    [(AFOpenFlowView *)self.view setImage:image forIndex:self.currentSelectedCover];
    [self.imagesArray replaceObjectAtIndex:self.currentSelectedCover withObject:image];
    return self.currentSelectedCover;
}


- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index
{    
    [self.delegate setSliderPosition:[self.theScene startTimeOfPictureIndex:index]];
    self.currentSelectedCover = index;
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
        //get a reference to the current selected photo
        Picture *pic = [theScene pictureForIndex:self.currentSelectedCover];
        
        CameraPopupViewController *overlayView = [[CameraPopupViewController alloc] initWithCoverScene:theCoverScene andContext:context originalHash:pic.hash cue:pic.theCue];
        
        [overlayView.view setAlpha:0.0];
        [self.view addSubview:overlayView.view];
        [UIView beginAnimations:nil context:nil];
        [overlayView.view setAlpha:1.0];
        [UIView commitAnimations];
        
        [delegate stopPlayer];
        
        [overlayView setDelegate:self];
    }

}

-(IBAction)pressManualButton
{
    
//    NSLog(@"exportMANFilename : %@",self.exportFilename);
    NSURL *url = [NSURL fileURLWithPath:[[ShowDAO userDocumentDirectory] stringByAppendingString:self.exportFilename]];
    [delegate playMovie:url];
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

- (IBAction) playTutorial:(id)sender
{
    //play tutorial video player
    [delegate playMovie:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo" ofType:@"m4v"]]];
}

@end

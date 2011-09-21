//
//  CameraPopupViewController.m
//  MMS-UI
//
//  Created by Adrian on 15/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraPopupViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation CameraPopupViewController

@synthesize takePhotoButton, replacePictureButton, popoverController, delegate;

-(void) dealloc
{
    [takePhotoButton release];
    [replacePictureButton release];
    [popoverController release];
    [super dealloc];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction) useCamera: (id)sender
{
//    [self.delegate takePhoto];
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
        
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentModalViewController:imagePicker
                            animated:YES];
        [imagePicker release];
    }
}

- (IBAction) useCameraRoll: (id)sender
{
    if ([self.popoverController isPopoverVisible]) {
        [self.popoverController dismissPopoverAnimated:YES];
        [popoverController release];
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                      (NSString *) kUTTypeImage,
                                      nil];
            imagePicker.allowsEditing = NO;
            
            self.popoverController = [[UIPopoverController alloc]
                                      initWithContentViewController:imagePicker];
            
            popoverController.delegate = self;
            
            [self.popoverController 
             presentPopoverFromRect: CGRectMake(500, 500, 1000.0f, 1000.0f) 
             inView:self.view 
             permittedArrowDirections:UIPopoverArrowDirectionDown 
             animated:YES];
            
            [imagePicker release];
        }
    }
}

- (IBAction) cancelCurrentOverlay
{

    [self.view setAlpha:1.0];
    [UIView beginAnimations:nil context:nil];
    [self.view setAlpha:0.0];
    [UIView commitAnimations];
    [self.view removeFromSuperview];
   
}

/* Called when the user had taken a photo or selected a photo from the photo library. */
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self.popoverController dismissPopoverAnimated:true];
    [popoverController release];
    
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
        
        //resize image
        CGSize size = CGSizeMake(640,480);
        if (image.size.height == 640 || image.size.height == 960){
            size = CGSizeMake(480,640);
        }
       
        image = [UIImage imageWithImage:image scaledToSize:size];
        //imageView.image = image;
        
        //replace image from imagesArray index 0 with new image
        [self.delegate replaceCenterImage:image];
        [self cancelCurrentOverlay];
        
        //removed codes that save photo to photo library
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

@end

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
@synthesize imagesArray;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
- (id)initWithArrayAndIndex:(NSMutableArray*)anArray indexOfImage:(NSInteger)anIndex
{
    self = [super init];
    if (self) {
        self.imagesArray = anArray;
        indexOfImageToChange = anIndex;
    }
    return self;
}

//- (id)initWithController:(PhotoEditorViewController*)controller
//{
//    photoEditViewController = controller;
//}

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

    //load the choosen image that is supposed to be replace
    [imageView setImage:[imagesArray objectAtIndex:indexOfImageToChange]];
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
        
//        self.popoverController = [[UIPopoverController alloc]
//                                  initWithContentViewController:imagePicker];
////        
//        popoverController.delegate = self;
//
//        
//        [self.popoverController 
//         presentPopoverFromRect: CGRectMake(-100, 500, 500, 500) 
//         inView:self.view 
//         permittedArrowDirections:UIPopoverArrowDirectionDown 
//         animated:YES]; 
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentModalViewController:imagePicker
                            animated:YES];
        [imagePicker release];
        newMedia = YES;
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
            newMedia = NO;
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


//-(UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height {
//	
//	CGImageRef imageRef = [image CGImage];
//	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
//	
//	//if (alphaInfo == kCGImageAlphaNone)
//    alphaInfo = kCGImageAlphaNoneSkipLast;
//	
//	CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), 4 * width, CGImageGetColorSpace(imageRef), alphaInfo);
//	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
//	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
//	UIImage *result = [UIImage imageWithCGImage:ref];
//	
//	CGContextRelease(bitmap);
//	CGImageRelease(ref);
//	
//	return result;	
//}
/* Called when the user had taken a photo or selected a photo from the photo library. */
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"I'm in didFinishPickingMediaWithInfo");
    
    [self.popoverController dismissPopoverAnimated:true];
    [popoverController release];
    
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
        
        //resize image
//        UIImage *resizedImage = [UIImage imageWithCGImage:image.CGImage Scale:0.25 Orientation:UIImageOrientationUp];
//        resizedImage = [self resizeImage:image width: 640 height: 480];
        image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(640,480)];
        
        //imageView.image = image;
        
        //replace image from imagesArray index 0 with new image
//        [self replaceImage:indexOfImageToChange newImage:image];
        [self.delegate replaceCenterImage:image];
        [self cancelCurrentOverlay];
        
        //removed codes that save photo to photo library
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
    
    [self refreshImageView]; //refresh the imageView
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
    
    NSLog(@"I'm in imagePickerControllerDidCancel");
}

- (void) replaceImage:(NSInteger)imageIndex newImage:(UIImage*)anImage 
{
    [imagesArray replaceObjectAtIndex:imageIndex withObject:anImage];
}

- (void)refreshImageView 
{
    [imageView setImage:[imagesArray objectAtIndex:indexOfImageToChange]];
} 

@end

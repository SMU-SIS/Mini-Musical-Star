//
//  CameraPopupViewController.m
//  MMS-UI
//
//  Created by Adrian on 15/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraPopupViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MiniMusicalStarUtilities.h"
#import "Cue.h"

@implementation CameraPopupViewController

@synthesize takePhotoButton, replacePictureButton, popoverController, delegate, context, theCoverScene, originalHash, theCue, cueView;

-(void) dealloc
{
    [takePhotoButton release];
    [replacePictureButton release];
    [popoverController release];
    [theCoverScene release];
    [originalHash release];
    [context release];
    [theCue release];
    [cueView release];
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
    UIImage *takePhotoImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"camera" ofType:@"png"]];
    [takePhotoButton setImage:takePhotoImage forState:UIControlStateNormal];
    UIImage *photoLibraryImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo_library" ofType:@"png"]];
    [replacePictureButton setImage:photoLibraryImage forState:UIControlStateNormal];
    
    //check if there is a cue, if there is display it
    if (self.theCue)
    {
        //create a view and plonk it on the screen
        UILabel *aLabel = [[UILabel alloc] init];
        aLabel.text = theCue.content;
        aLabel.font = [UIFont fontWithName:@"Helvetica" size:26];
        [aLabel sizeToFit];
        aLabel.textColor = [UIColor redColor];
        aLabel.textAlignment = UITextAlignmentCenter;
        
        CGRect frame = CGRectMake(0, 0, self.cueView.frame.size.width, self.cueView.frame.size.height);
        aLabel.frame = frame;
        
        [self.cueView addSubview:aLabel];
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

- (id)initWithCoverScene:(CoverScene *)coverScene andContext:(NSManagedObjectContext *)aContext originalHash:(NSString *)aOriginalHash cue:(Cue *)aCue
{
    self = [super init];
    if (self)
    {
        self.theCoverScene = coverScene;
        self.context = aContext;
        self.originalHash = aOriginalHash;
        self.theCue = aCue;
    }
    
    return self;
}

- (IBAction) useCamera: (id)sender
{
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
        
        //replace image in cover flow
        int selectedIndex = [self.delegate replaceCenterImage:image];
        [self cancelCurrentOverlay];
        
        //removed codes that save photo to photo library
        UIImageWriteToSavedPhotosAlbum(image,nil, nil, nil);
        
        //save photo to documents directory, then store path in core data
        
        //write image
        NSString *imageFileName = [MiniMusicalStarUtilities getUniqueFilenameWithoutExt];

        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:[@"Documents" stringByAppendingPathComponent:imageFileName]];
        
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
        
        // Point to Document directory
        NSString *documentsDirectoryImage = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageFileName];
        
        //save to coredata
        CoverScenePicture *newPicture = [NSEntityDescription insertNewObjectForEntityForName:@"CoverScenePicture" inManagedObjectContext:context];
        newPicture.OriginalHash = self.originalHash;
        newPicture.OrderNumber = [[NSNumber numberWithInt:(selectedIndex)] stringValue];
        newPicture.Path = documentsDirectoryImage;
        [theCoverScene addPictureObject:newPicture];
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

@end

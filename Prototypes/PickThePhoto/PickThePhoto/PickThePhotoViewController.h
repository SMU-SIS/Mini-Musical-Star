//
//  PickThePhotoViewController.h
//  PickThePhoto
//
//  Created by Tommi on 19/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PickThePhotoViewController : UIViewController
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIPopoverControllerDelegate>
{
    UIToolbar *toolbar;
    UIPopoverController *popoverController;
    UIImageView *imageView;
    BOOL newMedia;
    
    NSMutableArray *imagesArray;
    
    
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) NSMutableArray *imagesArray;

- (IBAction)useCamera: (id)sender;
- (IBAction)useCameraRoll: (id)sender;
- (void) replaceImage:(NSInteger*)imageIndex newImage:(UIImage*)anImage;
- (void) refreshImageView;

@end

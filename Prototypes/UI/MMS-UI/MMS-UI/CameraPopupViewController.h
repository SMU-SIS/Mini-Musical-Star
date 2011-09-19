//
//  CameraPopupViewController.h
//  MMS-UI
//
//  Created by Adrian on 15/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoEditorViewController.h"

@interface CameraPopupViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>
{
    //UI
    UIImageView *imageView;
    UIToolbar *toolbar;
    UIPopoverController *popoverController;
    
    
    
    NSMutableArray *imagesArray;
    BOOL newMedia;
    NSInteger indexOfImageToChange;
}

@property (nonatomic, retain) IBOutlet UIButton *takePhotoButton;
@property (nonatomic, retain) IBOutlet UIButton *replacePictureButton;


@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, retain) NSMutableArray *imagesArray;

- (id)initWithArrayAndIndex:(NSMutableArray*)anArray indexOfImage:(NSInteger)anIndex;

- (IBAction)useCamera: (id)sender;
- (IBAction)useCameraRoll: (id)sender;
- (void) replaceImage:(NSInteger)imageIndex newImage:(UIImage*)anImage;
- (void) refreshImageView;

- (IBAction) cancelOverlay:(UIButton *)sender;

@end


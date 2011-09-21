//
//  CameraPopupViewController.h
//  MMS-UI
//
//  Created by Adrian on 15/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraPopupViewDelegate <NSObject>
@required
- (void)replaceCenterImage: (UIImage*)image;
@end

@interface CameraPopupViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>
{
    UIPopoverController *popoverController;
    
    id <CameraPopupViewDelegate> delegate;

}

@property (nonatomic, assign) id <CameraPopupViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIButton *takePhotoButton;
@property (nonatomic, retain) IBOutlet UIButton *replacePictureButton;

@property (nonatomic, retain) UIPopoverController *popoverController;

- (IBAction)useCamera: (id)sender;
- (IBAction)useCameraRoll: (id)sender;

@end


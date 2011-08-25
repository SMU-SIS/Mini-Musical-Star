//
//  ImageReplacer.h
//  PickThePhoto
//
//  Created by Tommi on 25/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ImageReplacer : UIViewController
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

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, retain) NSMutableArray *imagesArray;

- (id)initWithArrayAndIndex:(NSMutableArray*)anArray indexOfImage:(NSInteger)anIndex;

- (IBAction)useCamera: (id)sender;
- (IBAction)useCameraRoll: (id)sender;
- (void) replaceImage:(NSInteger)imageIndex newImage:(UIImage*)anImage;
- (void) refreshImageView;

@end

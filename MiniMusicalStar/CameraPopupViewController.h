//
//  CameraPopupViewController.h
//  MMS-UI
//
//  Created by Adrian on 15/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoverScene.h"
#import "CoverScenePicture.h"

@class CoverScene, CoverScenePicture, Cue;

@protocol CameraPopupViewDelegate <NSObject>
@required
- (int)replaceCenterImage: (UIImage*)image;
@end

@interface CameraPopupViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>
{
    id <CameraPopupViewDelegate> delegate;
}

@property (nonatomic, assign) id <CameraPopupViewDelegate> delegate;

@property (retain, nonatomic) CoverScene *theCoverScene;
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (nonatomic, retain) IBOutlet UIButton *takePhotoButton;
@property (nonatomic, retain) IBOutlet UIButton *replacePictureButton;
@property (retain, nonatomic) IBOutlet UIView *cueView;
@property (retain, nonatomic) NSString *originalHash;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (retain, nonatomic) Cue *theCue;

- (id)initWithCoverScene:(CoverScene *)coverScene andContext:(NSManagedObjectContext *)aContext originalHash:(NSString *)aOriginalHash cue:(Cue *)theCue;
- (IBAction)viewCue: (id)sender;
- (IBAction)useCamera: (id)sender;
- (IBAction)useCameraRoll: (id)sender;

@end


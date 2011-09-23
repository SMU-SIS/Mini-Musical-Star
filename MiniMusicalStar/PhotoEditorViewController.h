//
//  PhotoEditorViewController.h
//  CrollUI
//
//  Created by Jun Kit Lee on 8/9/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Show.h"
#import "ShowDAO.h"
#import "Picture.h"
#import "AFOpenFlowView.h"
#import "CameraPopupViewController.h"
#import "CoverScene.h"
#import "CoverScenePicture.h"

@protocol PhotoEditorViewDelegate <NSObject>
- (void) setSliderPosition: (int) seconds;
- (void)stopPlayer;
@end

@interface PhotoEditorViewController : UIViewController <AFOpenFlowViewDelegate,AFOpenFlowViewDataSource, CameraPopupViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
    NSOperationQueue *loadImagesOperationQueue;
    
    id <PhotoEditorViewDelegate> delegate;

}

@property(retain,nonatomic) IBOutlet UIImageView *leftPicture;
@property(retain,nonatomic) IBOutlet UIImageView *rightPicture;
@property(retain,nonatomic) IBOutlet UIImageView *centerPicture;
@property(retain,nonatomic) NSArray *thePictures;
@property (retain,nonatomic) NSMutableArray *imagesArray;
@property (nonatomic) int currentSelectedCover;

@property (nonatomic, assign) id <PhotoEditorViewDelegate> delegate;

@property (retain, nonatomic) CoverScene *theCoverScene;
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) CameraPopupViewController *cameraPopupViewController;

- (PhotoEditorViewController *)initWithPhotos:(NSArray *)pictureArray andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)context;

- (IBAction) popupCameraOptions: (id) sender;

- (void) setSliderImages:(UInt32)timeAt;
- (int)replaceCenterImage: (UIImage*)image;
- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index;


@end
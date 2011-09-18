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

@interface PhotoEditorViewController : UIViewController <AFOpenFlowViewDelegate,AFOpenFlowViewDataSource> {
    NSOperationQueue *loadImagesOperationQueue;
}

@property(retain,nonatomic) IBOutlet UIImageView *leftPicture;
@property(retain,nonatomic) IBOutlet UIImageView *rightPicture;
@property(retain,nonatomic) IBOutlet UIImageView *centerPicture;
@property(retain,nonatomic) NSArray *thePictures;
@property (retain,nonatomic) NSMutableArray *imagesArray;
@property (nonatomic) int currentSelectedCover;

@property (retain, nonatomic) CoverScene *theCoverScene;
@property (retain, nonatomic) NSManagedObjectContext *context;

- (void) setSliderImages:(UInt32)timeAt;
- (PhotoEditorViewController *)initWithPhotos:(NSArray *)pictureArray andCoverScene:(CoverScene *)aCoverScene andContext:(NSManagedObjectContext *)context;
- (IBAction) pressCenterImage;
- (IBAction) replaceImageTest:(UIButton *)sender;

@end

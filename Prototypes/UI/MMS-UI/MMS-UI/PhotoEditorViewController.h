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
#import "SceneEditViewController.h"

@interface PhotoEditorViewController : UIViewController

@property(retain,nonatomic) IBOutlet UIImageView *leftPicture;
@property(retain,nonatomic) IBOutlet UIImageView *rightPicture;
@property(retain,nonatomic) IBOutlet UIImageView *centerPicture;
@property(retain,nonatomic) NSArray *thePictures;

- (void) setSliderImages:(UInt32)timeAt;
- (PhotoEditorViewController *)initWithPhotos:(NSArray *)pictureArray;
@end

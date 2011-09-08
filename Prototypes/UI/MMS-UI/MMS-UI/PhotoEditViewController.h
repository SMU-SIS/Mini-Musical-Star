//
//  PhotoEditViewController.h
//  MMS-UI
//
//  Created by Adrian on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoEditViewController : UIViewController

@property(retain,nonatomic) IBOutlet UIImageView *mainPicture;
@property(retain,nonatomic) IBOutlet UIImageView *leftPicture;
@property(retain,nonatomic) IBOutlet UIImageView *rightPicture;
@property(retain,nonatomic) IBOutlet UIImageView *centerPicture;

-(IBAction)clickCenterPicture:(UIImageView *)sender;
-(IBAction)clickRightPicture;
-(IBAction)clickLeftPicture;

@end

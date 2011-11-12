//
//  ProgressOverlayViewController.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressOverlayViewController : UIViewController

@property(retain,nonatomic) IBOutlet UIProgressView *progressView;
@property(retain,nonatomic) IBOutlet UIButton *cancelButton;

-(IBAction)cancelProgressView:(id)sender;

@end

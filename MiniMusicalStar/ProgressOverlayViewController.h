//
//  ProgressOverlayViewController.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProgressOverlayViewDelegate <NSObject>
- (void) cancelExportSession;
@end

@interface ProgressOverlayViewController : UIViewController
{
    id <ProgressOverlayViewDelegate> delegate;
}

@property (nonatomic, assign) id <ProgressOverlayViewDelegate> delegate;

@property(retain,nonatomic) IBOutlet UIProgressView *progressView;
@property(retain,nonatomic) IBOutlet UIButton *cancelButton;

-(IBAction)cancelProgressView:(id)sender;
-(void) changeCancelToDoneButton;

@end

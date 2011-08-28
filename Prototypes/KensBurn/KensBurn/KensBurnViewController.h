//
//  KensBurnViewController.h
//  KensBurn
//
//  Created by Tommi on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KensBurnViewController : UIViewController
{
    IBOutlet UIImageView* imageView;
}

@property (nonatomic, retain) UIImageView *imageView;

- (IBAction)startStopButtonClicked;
- (void)startKensBurn;

@end

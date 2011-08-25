//
//  PickThePhoto2ViewController.h
//  PickThePhoto2
//
//  Created by Tommi on 25/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickThePhoto2ViewController : UIViewController
{
    NSMutableArray* imagesArray;
    
    //UI
    IBOutlet UIButton* callModalButton;
}

@property (nonatomic, retain) NSMutableArray *imagesArray;

@property (nonatomic, retain) UIButton *callModalButton;

- (IBAction)callModal;

@end

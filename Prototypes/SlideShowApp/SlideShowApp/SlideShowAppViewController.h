//
//  SlideShowAppViewController.h
//  SlideShowApp
//
//  Created by Tommi on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideShowAppViewController : UIViewController {
    /* UI objects */
    UIImageView* imageView;
    UIButton* nextButton;
    
    int imgCounter;
    int imagesArraySize;
    NSArray* imagesArray;
}

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIButton* nextButton;

- (IBAction)myButtonPressed:(id)sender;

@end

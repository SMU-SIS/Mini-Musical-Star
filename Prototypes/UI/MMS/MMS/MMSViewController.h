//
//  MMSViewController.h
//  MMS
//
//  Created by Weijie Tan on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Create.h"
#import "MenuImage.h"

@interface MMSViewController : UIViewController {
    IBOutlet UIScrollView *scrollView;
    
    MenuImage *menuImage;
}

-(IBAction)createMusical;
-(int)currentPage;

@end

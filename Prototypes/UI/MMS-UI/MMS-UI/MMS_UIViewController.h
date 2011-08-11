//
//  MMS_UIViewController.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"
#import "Create.h"

@interface MMS_UIViewController : UIViewController {
    IBOutlet UIScrollView *scrollView;
    
    ShowImage *showImages;
}

-(IBAction)createMusical;
-(int)currentPage;

@end

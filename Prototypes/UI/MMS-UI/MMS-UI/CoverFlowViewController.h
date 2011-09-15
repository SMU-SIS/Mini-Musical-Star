//
//  CoverFlowViewController.h
//  MMS-UI
//
//  Created by Adrian on 15/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFOpenFlowView.h"

@interface CoverFlowViewController : UIViewController <AFOpenFlowViewDelegate,AFOpenFlowViewDataSource> {
	
    // Queue to hold the cover flow images
	
	NSOperationQueue *loadImagesOperationQueue;
    
}
@end
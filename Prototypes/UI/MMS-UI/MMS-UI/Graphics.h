//
//  Graphics.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"


@interface Graphics : UIViewController {
    IBOutlet UIScrollView *scrollView;
    
    ShowImage *showImage;
}

@end

//
//  MMS_UIViewController.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"
#import "EditViewController.h"
#import "SceneViewController.h"
#import "PlaybackViewController.h"
#import "CoverViewController.h"

@interface MenuViewController : UIViewController {
    IBOutlet UIScrollView *scrollView; 
    
    ShowImage *showImages;
}

-(IBAction)createMusical;
-(IBAction)playBackMusical;
-(IBAction)coverMusical;

-(int)currentPage;
-(void)displayShowImages:(NSArray *)images;

@end

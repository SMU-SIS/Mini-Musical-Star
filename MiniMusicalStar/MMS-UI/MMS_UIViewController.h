//
//  MMS_UIViewController.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowImage.h"
#import "Edit.h"
#import "SceneUI.h"
#import "Playback.h"
#import "Cover.h"
#import "ShowDAO.h"

@interface MMS_UIViewController : UIViewController {
    IBOutlet UIScrollView *scrollView;
    
    ShowImage *showImages;
}

@property (retain, nonatomic) NSArray *shows;

-(IBAction)createMusical;
-(IBAction)playBackMusical;
-(IBAction)coverMusical;

-(int)currentPage;

@end

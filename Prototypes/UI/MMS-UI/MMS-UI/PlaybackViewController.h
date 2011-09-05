//
//  Playback.h
//  MMS-UI
//
//  Created by Weijie Tan on 8/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScenePlayer.h"
#import "Show.h"

@interface PlaybackViewController : UIViewController {
    IBOutlet UIView *playbackView;
    ScenePlayer *player;
    Show *theShow;
    Scene *theScene;
}

@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Scene *theScene;
@property (retain, nonatomic) UIView *playbackView;
@property (retain, nonatomic) ScenePlayer *player;

-(IBAction)backToMenu;

@end

//
//  SceneStripController.m
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 29/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SceneStripController.h"
#import "Show.h"
#import "Cover.h"
#import "CoverScene.h"
#import "SceneEditViewController.h"

@implementation SceneStripController
@synthesize view, theShow, theCover, context, delegate, coverLabel;

- (void)dealloc
{
    [coverLabel release];
    [context release];
    [theShow release];
    [theCover release];
    [view release];
    [super dealloc];
}

- (id)initWithShow:(Show *)aShow Cover:(Cover *)aCover 
{
    self = [super init];
    if (self)
    {
        self.view = [[UIScrollView alloc] initWithFrame:CGRectMake(1024,368,1024,275)];
        self.theShow = aShow;
        self.theCover = aCover;
        
        [self loadSceneSelectionScrollView];
    }
    
    return self;
}

- (void)setCoverTitleLabel:(NSString*) text
{
    [self.coverLabel setText:text];
}

- (void)loadSceneSelectionScrollView
{
    self.view.scrollEnabled = YES;
    self.view.showsHorizontalScrollIndicator = NO;
    self.view.showsVerticalScrollIndicator = NO;
    self.view.pagingEnabled = NO;
    self.view.clipsToBounds = YES;
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"stripsceneselection.png"]];
    self.view.backgroundColor = background;
    
    self.coverLabel = [[UILabel alloc] initWithFrame:CGRectMake(1024+100,20,500,75)];
//    self.coverLabel.transform = CGAffineTransformMakeRotation(90);
    [coverLabel setFont:[UIFont fontWithName:@"Arial" size:30]];
    [coverLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:coverLabel];
    
    //look at the scene order dictionary in the Show object to place the scenes in the correct order
    [self.theShow.scenesOrder enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *sceneHash = (NSString *)obj;
        Scene *theScene = [self.theShow.scenes objectForKey:sceneHash];
        
        //do a bit of sanity check
        if (!theScene) NSLog(@"Cannot find scene with hash %@ in the plist file.\n", sceneHash);
        
        //create the button's frame
        CGRect frame;
        frame.origin.x = 38 + view.frame.origin.x + idx * 274;
        frame.origin.y = 93;
        frame.size.width = 200;
        frame.size.height = 150;
        
        //create the actual button
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        
        //set tag number for each scene button to correspond with the scene order dict
        [button setTag:idx];
        [button setImage: theScene.coverPicture forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(selectScene:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [button release];
    }];
    
    //set the content size of the scrollview and check to see if the scrollview is overflowing
    int extend = 0;    
    if (self.theShow.scenes.count > 4) extend = self.theShow.scenes.count - 4;
    
    [self.view setContentSize:CGSizeMake(self.view.frame.size.width + (extend * 200), 0)];
}

-(void)selectScene:(UIButton *)sender
{
    if ([delegate respondsToSelector:@selector(showActivitySpinner)])
    {
        [delegate performSelector:@selector(showActivitySpinner)];
        [self performSelectorInBackground:@selector(loadSceneEditViewController:) withObject:sender];
    }
    //[DSBezelActivityView newActivityViewForView:self.view withLabel:@"Loading..."];
}

//need to do this because it takes some time to load the next controller. can display the loading spinner like that.
-(void)loadSceneEditViewController:(UIButton *)sender
{
    //this method is run in a separate thread so need an autorelease pool specially for this
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //attempt to get the Scene from the Scenes dictionary for the key, which in turn is gotten from the scene order array
    Scene *selectedScene = [self.theShow.scenes objectForKey:[self.theShow.scenesOrder objectAtIndex:sender.tag]];
    
    CoverScene *selectedCoverScene = [theCover coverSceneForSceneHash:selectedScene.hash];
    
    if (!selectedCoverScene)
    {
        //create a new CoverScene
        selectedCoverScene = [NSEntityDescription insertNewObjectForEntityForName:@"CoverScene" inManagedObjectContext:context];
        selectedCoverScene.SceneHash = selectedScene.hash;
        [self.theCover addScenesObject:selectedCoverScene];
        
        NSError *err;
        [self.context save:&err];
        
        //if (err != nil) NSLog(@"%@",[err localizedDescription]);
            
    }
    
    SceneEditViewController *editController = [[SceneEditViewController alloc] initWithScene:selectedScene andSceneCover:selectedCoverScene andContext:context];
    editController.title = selectedScene.title;
    
    [pool release];
    
    [self performSelectorOnMainThread:@selector(finishLoadingSceneEditViewController:) withObject:editController waitUntilDone:NO];
}

-(void)finishLoadingSceneEditViewController:(SceneEditViewController *)theController
{
    if ([delegate respondsToSelector:@selector(pushSceneEditViewController:)])
    {
        [delegate performSelector:@selector(pushSceneEditViewController:) withObject:[theController autorelease]];
    }
}



@end

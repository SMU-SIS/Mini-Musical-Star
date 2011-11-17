//
//  SceneStripController.h
//  MiniMusicalStar
//
//  Created by Lee Jun Kit on 29/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Show;
@class Cover;

@interface SceneStripController : NSObject

@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) UIImageView *ribbonImageView;
@property (retain, nonatomic) UIView *view;
@property (retain, nonatomic) UILabel *coverLabel;
@property (retain, nonatomic) Show *theShow;
@property (retain, nonatomic) Cover *theCover;
@property (assign, nonatomic) id delegate;
@property (retain, nonatomic) NSManagedObjectContext *context;

- (void)setCoverTitleLabel:(NSString*) text;
- (id)initWithShow:(Show *)aShow Cover:(Cover *)aCover;
- (void)loadSceneSelectionScrollView;

@end

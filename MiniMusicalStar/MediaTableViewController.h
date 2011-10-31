//
//  MediaTableViewController.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 31/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cover.h"

@protocol MediaTableViewDelegate <NSObject>
- (void) playMovie:(NSURL*)filePath;
@end

@interface MediaTableViewController : UITableViewController
{
    id <MediaTableViewDelegate> delegate;
}

@property (nonatomic, assign) id <MediaTableViewDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) Cover *theCover;
@property (retain, nonatomic) NSFetchedResultsController *frc;

@property (nonatomic, retain) NSMutableArray *exportedAssetArray;

@property (nonatomic, retain) UIImage *facebookUploadImage;
@property (nonatomic, retain) UIImage *youtubeUploadImage;

- (id)initWithStyle:(UITableViewStyle)style withCover:(Cover*)cover withContext:(NSManagedObjectContext*)ctxt;

- (void) populateTable;

@end

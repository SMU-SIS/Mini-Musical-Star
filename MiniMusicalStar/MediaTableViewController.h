//
//  MediaTableViewController.h
//  MiniMusicalStar
//
//  Created by Adrian Cheng Bing Jie on 31/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MediaTableViewDelegate <NSObject>
- (void) playMovie:(NSURL*)filePath;
@end

@interface MediaTableViewController : UITableViewController
{
    id <MediaTableViewDelegate> delegate;
}

@property (nonatomic, assign) id <MediaTableViewDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (retain, nonatomic) NSFetchedResultsController *frc;

@property (nonatomic, retain) NSMutableArray *exportedAssetArray;

- (id)initWithStyle:(UITableViewStyle)style withContext:(NSManagedObjectContext*)context;

- (void) populateTable;

@end

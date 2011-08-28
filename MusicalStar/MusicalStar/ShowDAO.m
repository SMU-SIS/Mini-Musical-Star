//
//  ShowDAO.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "ShowDAO.h"

@implementation ShowDAO

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (void)loadLocalShows
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask ,YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
}

+ (void)retrieveNewShowsFromServer
{
    
}
@end

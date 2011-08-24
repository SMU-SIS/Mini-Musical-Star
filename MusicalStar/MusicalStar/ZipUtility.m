//
//  ZipUtility.m
//  MusicalStar
//
//  Created by Adrian on 24/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZipUtility.h"

@implementation ZipUtility

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) unpackageMusical
{
    NSString *zipFilePath = [[NSBundle mainBundle] pathForResource:@"Story of my Life" ofType:@"zip"];
    ZipArchive* za = [[ZipArchive alloc] init];
    if( [za UnzipOpenFile:zipFilePath] ){
        BOOL ret = [za UnzipFileTo:@"/Users/adrian/Desktop/hihi" overWrite:YES];
        if( NO==ret )
        {
            NSLog(@"you have hit shit");
        }
        [za UnzipCloseFile];
    }
    
    [za release];
}

@end

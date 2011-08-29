//
//  ShowDAO.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "ShowDAO.h"

@implementation ShowDAO

static NSMutableArray *loadedShows;
static bool initialized = NO;

//+ (void)initialize
//{
//    
//}

+ (void)loadLocalShows
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask ,YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSLog(@"document directory is %@\n", documentDirectory);
    
    NSString *showsDirectory = [documentDirectory stringByAppendingString:@"/shows"];    
    
    //create it
    [manager createDirectoryAtPath:showsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    
    //list the directory structure
    NSArray *showsDirectoryListing = [manager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:showsDirectory] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    
    loadedShows = [[NSMutableArray alloc] initWithCapacity:showsDirectoryListing.count]; 
    
    //read the showMetaData.plist file for every Show
    [showsDirectoryListing enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *showDirectoryURL = (NSURL *)obj;
        NSLog(@"showDirectoryURL: %@",showDirectoryURL);
        
        //get a reference to showMetaData.plist url
        NSURL *metadataURL = [showDirectoryURL URLByAppendingPathComponent:@"showMetaData.plist"];
        NSString *metadataString = [metadataURL path];
        NSLog(@"metadataString is %@\n", metadataString);
        
        Show *show = [[Show alloc] initShowWithPropertyListFile:metadataString atPath:showDirectoryURL];
        [loadedShows addObject:show];
        [show release];
        
    }];
    
    initialized = YES;
}

+ (NSArray *)shows
{
    if (!initialized) [self loadLocalShows];
    
    return [loadedShows autorelease];
}

+ (void)retrieveNewShowsFromServer
{
    
}
@end

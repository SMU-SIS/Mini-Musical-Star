//
//  Show.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Show.h"

@implementation Show
@synthesize scenes, title, author;

- (Show *)initWithPropertyListFile: (NSString *)pListFilePath
{
    self = [super init];
    if (self) {
        
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:pListFilePath];
        NSDictionary *data = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];
        if (!data) {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
        
        NSLog(@"%@",data);
        
    }
    
    return self;
}



- (void)dealloc
{
    [scenes release];
}

@end

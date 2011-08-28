//
//  Show.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Show.h"

@implementation Show
@synthesize data, scenes, title, author, coverPicture, createdDate;

- (Show *)initWithPropertyListFile: (NSString *)pListFilePath
{
    self = [super init];
    if (self) {
        
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:pListFilePath];
        data = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];
        if (!data) {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
        
//        NSLog(@"%@",data);
        
        NSDictionary *root = [data objectForKey:@"root"];
        //populate the properties of the Show model
        title = [root objectForKey:@"title"];
        author = [root objectForKey:@"author"];
        coverPicture = [UIImage imageNamed:[root objectForKey:@"cover-picture"]];
        createdDate = [root objectForKey:@"created"];
        
        //get the scene data
        NSArray *scenesArray = [root objectForKey:@"scenes"];
        scenes = [[NSMutableArray alloc] initWithCapacity:scenesArray.count];
        
        [scenesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *sceneDict = (NSDictionary *)obj;
            
            Scene *scene = [[Scene alloc] initWithPropertyDictionary: sceneDict];
            [scenes addObject:scene];
            [scene release];
        }];
    }
    
    return self;
}



- (void)dealloc
{
    [data release];
    [coverPicture release];
    [author release];
    [title release];
    [scenes release];
    [createdDate release];
    [super dealloc];
}

@end

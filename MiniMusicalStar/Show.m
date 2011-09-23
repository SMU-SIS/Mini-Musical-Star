//
//  Show.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Show.h"

@implementation Show
@synthesize data, scenes, title, author, coverPicture, createdDate, iTunesAlbumLink, iBooksBookLink, showLocation, showID;

- (Show *)initShowWithPropertyListFile: (NSString *)pListFilePath atPath:(NSURL *)showPath
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
        
        NSDictionary *root = [data objectForKey:@"root"];
        //populate the properties of the Show model
        showLocation = showPath;
        self.showID = [[root objectForKey:@"id"] intValue];
        self.title = [root objectForKey:@"title"];
        self.author = [root objectForKey:@"author"];
        self.iTunesAlbumLink = [root objectForKey:@"iTunesAlbumLink"];
        self.iBooksBookLink = [root objectForKey:@"iBooksBookLink"];
        
        NSString *coverPicturePath = [[showLocation path] stringByAppendingPathComponent:[root objectForKey:@"cover-picture"]];

        self.coverPicture = [UIImage imageWithContentsOfFile:coverPicturePath];
        
        self.createdDate = [root objectForKey:@"created"];
        
        //get the scene data
        NSArray *scenesArray = [root objectForKey:@"scenes"];
        scenes = [[NSMutableArray alloc] initWithCapacity:scenesArray.count];
        
        [scenesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *sceneDict = (NSDictionary *)obj;
            NSString *sceneNumber = [sceneDict objectForKey:@"scene-number"];
            NSString *scenePath = [[[[showPath path] stringByAppendingString: @"/scenes/"] stringByAppendingString: sceneNumber] stringByAppendingString: @"/"];
            Scene *scene = [[Scene alloc] initSceneWithPropertyDictionary: sceneDict atPath:scenePath];
            
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
    [iTunesAlbumLink release];
    [iBooksBookLink release];
    [showLocation release];
    [super dealloc];
}

@end
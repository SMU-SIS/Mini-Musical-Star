//
//  Show.m
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import "Show.h"

@implementation Show
@synthesize data, scenes, scenesOrder, title, author, createdDate, iTunesAlbumLink, iBooksBookLink, showAssetsLocation, showID, coverPicture, showDescription;


- (void)dealloc
{
    [data release];
    [scenesOrder release];
    [coverPicture release];
    [author release];
    [title release];
    [scenes release];
    [createdDate release];
    [iTunesAlbumLink release];
    [iBooksBookLink release];
    [showAssetsLocation release];
    [showDescription release];
    [super dealloc];
}

- (Show *)initShowWithPropertyListFile: (NSString *)pListFilePath atPath:(NSURL *)showPath
{
    self = [super init];
    if (self) {
        
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:pListFilePath];
        self.data = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];
        if (!data) {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
        
        NSDictionary *root = [data objectForKey:@"root"];
        
        //set the location of the show assets
        self.showAssetsLocation = [[showPath path] stringByAppendingPathComponent:@"assets"];
        
        //populate the properties of the Show model
        self.showID = [[root objectForKey:@"id"] intValue];
        self.title = [root objectForKey:@"title"];
        self.author = [root objectForKey:@"author"];
        self.showDescription = [root objectForKey:@"description"];
        self.iTunesAlbumLink = [root objectForKey:@"iTunesAlbumLink"];
        self.iBooksBookLink = [root objectForKey:@"iBooksBookLink"];
        self.createdDate = [root objectForKey:@"created"];
        NSString *coverPicturePath = [self.showAssetsLocation stringByAppendingPathComponent:[root objectForKey:@"cover-picture"]];
        self.coverPicture = [UIImage imageWithContentsOfFile:coverPicturePath];
        
        //load the scenes dictionary
        NSDictionary *plistScenesDictionary = [root objectForKey:@"scenes"];
        self.scenes = [NSMutableDictionary dictionaryWithCapacity:[plistScenesDictionary count]];
        
        [plistScenesDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            Scene *scene = [[Scene alloc] initWithHash:(NSString *)key dictionary:(NSDictionary *)obj assetPath:showAssetsLocation];
            [self.scenes setObject:scene forKey:(NSString *)key];
            [scene release];
        }];
        
        //load the scenes ordering array
        self.scenesOrder = [root objectForKey:@"scenes-order"];
    }
    
    return self;
}

- (void)setCoverPicture:(UIImage *)aCoverPicture
{
    coverPicture = [aCoverPicture retain];
}

- (UIImage *)coverPicture
{
    if (coverPicture)
    {
        return coverPicture;
    }
    
    else
    {
        NSString *placeholderSceneImage = [[NSBundle mainBundle] pathForResource:@"musical_placeholder" ofType:@"png"];
        return [[[UIImage alloc] initWithContentsOfFile:placeholderSceneImage] autorelease];
    }
}

- (Scene *)sceneForIndex:(int)idx
{
    return [self.scenes objectForKey:[self.scenesOrder objectAtIndex:idx]];
}



@end

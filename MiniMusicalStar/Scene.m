//
//  Scene.m
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Scene.h"
#import "Audio.h"
#import "Picture.h"

@implementation Scene
@synthesize hash, title, description, audioDict, pictureDict, coverPicture, pictureTimingDict, pictureTimingsArray;

- (void)dealloc
{
    [hash release];
    [title release];
    [description release];
    [audioDict release];
    [pictureTimingDict release];
    [pictureTimingsArray release];
    [pictureDict release];
    [super dealloc];
}

-(id) initWithHash:(NSString *)aHash dictionary:(NSDictionary *)dictionary assetPath:(NSString *)assetPath
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.hash = aHash;
        self.title = [dictionary objectForKey:@"title"];
        
        NSString *picturePath = [assetPath stringByAppendingPathComponent:[dictionary objectForKey:@"cover-picture"]];
        self.coverPicture = [[UIImage alloc] initWithContentsOfFile:picturePath];
        
        self.description = [dictionary objectForKey:@"description"];
        //init the audio stuff here
        NSMutableDictionary *plistAudioDict = [dictionary objectForKey:@"audio"];
        self.audioDict = [NSMutableDictionary dictionaryWithCapacity:[plistAudioDict count]];
        
        [plistAudioDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            Audio *audioTrack = [[Audio alloc] initWithHash:(NSString *)key dictionary:(NSDictionary *)obj assetPath:assetPath];
            [self.audioDict setObject:audioTrack forKey:audioTrack.hash];
            [audioTrack release];
        }];
        
        //init the picture stuff here
        NSMutableDictionary *plistPicturesDict = [dictionary objectForKey:@"pictures"];
        self.pictureDict = [NSMutableDictionary dictionaryWithCapacity:[plistPicturesDict count]];
        
        [plistPicturesDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            Picture *aPicture = [[Picture alloc] initWithHash:(NSString *)key dictionary:(NSDictionary *)obj assetPath:assetPath];
            [self.pictureDict setObject:aPicture forKey:aPicture.hash];
        }];
        
        //init the picture order dictionary - startTimeInSeconds::picture hash
        self.pictureTimingDict = [dictionary objectForKey:@"pictures-timing"];
        
        //create an array of timings and SORT THEM
        self.pictureTimingsArray = [NSMutableArray arrayWithArray:[self.pictureTimingDict allKeys]];
        
        [self.pictureTimingsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *strObj1 = (NSString *)obj1;
            NSString *strObj2 = (NSString *)obj2;
            
            if ([strObj1 intValue] > [strObj2 intValue])
            {
                return NSOrderedDescending;
            }
            
            else
            {
                return NSOrderedAscending;
            }
        }];
        
    }
    
    return self;
}

- (Picture *)pictureForIndex:(int)index
{
    //get the start time for this index
    NSString *startTime = [pictureTimingsArray objectAtIndex:index];
    NSString *pictureHash = [pictureTimingDict objectForKey:startTime];
    
    return [pictureDict objectForKey:pictureHash];
}

- (Picture *)pictureForAbsoluteSecond:(int)second
{
    //convert the int seconds to the plist/dictionary friendly string
    NSString *wantedSeconds = [NSString stringWithFormat:@"%i", second];
    
    NSString *pictureHash = [pictureTimingDict objectForKey:wantedSeconds];
    return [pictureDict objectForKey:pictureHash];
}

- (Picture *)pictureForSeconds:(int)second
{
    Picture *picture = [self pictureForAbsoluteSecond:second];
    
    while (picture == nil)
    {
        picture = [self pictureForAbsoluteSecond:second--];
    }
    
    return picture;
}

- (int)pictureNumberToShowForSeconds:(int)second
{
    int order = NSNotFound;
    
    do {
        order = [self.pictureTimingsArray indexOfObject:[NSString stringWithFormat:@"%i", second]];
        second--;
    } while (order == NSNotFound);
    
    return order;

}

- (int)startTimeOfPictureIndex:(int)index
{
    //get the seconds corresponding to the picture index
    return [[self.pictureTimingsArray objectAtIndex:index] intValue];
}

- (NSMutableArray*) getOrderedPictureTimingArray
{
    NSMutableArray *sortedTimingsArray = [NSMutableArray arrayWithArray:[self.pictureTimingDict allKeys]];
    [sortedTimingsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *strObj1 = (NSString *)obj1;
        NSString *strObj2 = (NSString *)obj2;
        
        if ([strObj1 intValue] > [strObj2 intValue])
        {
            return NSOrderedDescending;
        }
        
        else
        {
            return NSOrderedAscending;
        }
    }];
    
    return sortedTimingsArray;
}

- (UIImage *)coverPicture
{
    
    if (coverPicture != nil)
    {
        return coverPicture;
    }
    
    else
    {
        NSString *placeholderSceneImage = [[NSBundle mainBundle] pathForResource:@"scene_placeholder" ofType:@"png"];
        return [[[UIImage alloc] initWithContentsOfFile:placeholderSceneImage] autorelease];
    }
}

- (NSArray *)arrayOfAudioTrackURLs
{
    __block NSMutableArray *audioTracks = [NSMutableArray arrayWithCapacity:self.audioDict.count];
    [self.audioDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        Audio *theAudioTrack = (Audio *)obj;
        [audioTracks addObject:[NSURL fileURLWithPath:theAudioTrack.path]];
    }];
    
    return audioTracks;
}

- (NSArray *)audioTracks
{
    NSMutableArray *audioTracks = [[NSMutableArray alloc] initWithCapacity:[self.audioDict count]];
    [self.audioDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [audioTracks addObject:obj];
    }];
    
    return [audioTracks autorelease];
}


@end

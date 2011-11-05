//
//  Scene.h
//  MusicalStar
//
//  Created by Adrian on 28/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Audio;
@class Picture;
@interface Scene : NSObject {
}

@property (retain, nonatomic) NSString *hash;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *description;
@property (retain, nonatomic) NSMutableDictionary *audioDict;
@property (retain, nonatomic) NSMutableDictionary *pictureDict;
@property (retain, nonatomic) NSMutableDictionary *pictureTimingDict;
@property (retain, nonatomic) NSMutableArray *pictureTimingsArray;
@property (retain, nonatomic) UIImage *coverPicture;

-(id) initWithHash:(NSString *)hash dictionary:(NSDictionary *)dictionary assetPath:(NSString *)assetPath;
-(Picture *)pictureForSeconds:(int)second;
- (Picture *)pictureForAbsoluteSecond:(int)second;
- (int)pictureNumberToShowForSeconds:(int)second;
- (int)startTimeOfPictureIndex:(int)index;
- (Picture *)pictureForIndex:(int)index;
-(NSArray *)arrayOfAudioTrackURLs;
-(NSArray *)audioTracks;
- (NSMutableArray*) getOrderedPictureTimingArray;

@end

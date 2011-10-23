//
//  YouTubeUploader.h
//  MiniMusicalStar
//
//  Created by Tommi on 23/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDataServiceGoogleYouTube.h"

@interface YouTubeUploader : NSObject
{
    GDataServiceTicket *mUploadTicket;
}

- (GDataServiceGoogleYouTube *)youTubeService;

- (void)setUploadTicket:(GDataServiceTicket *)ticket;

- (void)uploadVideoFile;

@end

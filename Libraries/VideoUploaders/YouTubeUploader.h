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

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

- (GDataServiceGoogleYouTube *)youTubeService;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;
- (void)uploadWithProperties:(NSURL*)aVideoNSURL title:(NSString*)aTitle desription:(NSString*)aDescription;
- (void)setUserCredentials:(NSString*)aUsername password:(NSString*)aPassword;

@end

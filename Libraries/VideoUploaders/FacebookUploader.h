//
//  MMSFacebook.h
//  MiniMusicalStar
//
//  Created by Tommi on 22/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"


@interface FacebookUploader : NSObject
    <FBSessionDelegate, FBRequestDelegate>
{
    Facebook *facebook;
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSURL *videoNSURL;
@property (nonatomic, retain) NSString *videoTitle;
@property (nonatomic, retain) NSString *videoDescription;

- (void)uploadToFacebook;
- (void)uploadVideoWithProperties:(NSURL*)aVideoNSURL title:(NSString*)aTitle desription:(NSString*)aDescription;

@end

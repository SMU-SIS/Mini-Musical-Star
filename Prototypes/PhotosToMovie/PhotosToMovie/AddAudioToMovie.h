//
//  AddAudioToMovie.h
//  PhotosToMovie
//
//  Created by Jun Kit on 28/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AddAudioToMovie : NSObject {
    
}

- (AVAsset *)addAudioToMovie:(NSString *)moviePath;

@end

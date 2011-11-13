//
//  CoversFilenameGenerator.h
//  MiniMusicalStar
//
//  Created by Tommi on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MiniMusicalStarUtilities : NSObject

+ (NSString*)returnMD5HashOfData:(NSData*)aData;
+ (NSString*)returnMD5HashOfString:(NSString*)aString;
+ (NSString*)getUniqueFilenameWithoutExt;
+ (BOOL) NSStringIsValidEmail:(NSString *)checkString;

@end

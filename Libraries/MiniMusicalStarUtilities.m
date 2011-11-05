//
//  CoversFilenameGenerator.m
//  MiniMusicalStar
//
//  Created by Tommi on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MiniMusicalStarUtilities.h"

#import <CommonCrypto/CommonDigest.h>

@implementation MiniMusicalStarUtilities

//generate md5 hash from data
+ (NSString *) returnMD5HashOfData:(NSData*)aData 
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(aData.bytes, aData.length, result);
    NSMutableString *hash = [NSMutableString string];
    
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    
    return [hash lowercaseString];
}

//generate md5 hash from data
+ (NSString *) returnMD5HashOfString:(NSString*)aString 
{
    // Create pointer to the string as UTF8
    const char *ptr = [aString UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (NSString*)getUniqueFilenameWithoutExt
{
    NSString *timeIntervalInString = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSString *uniqueFilename = [MiniMusicalStarUtilities returnMD5HashOfString:timeIntervalInString];
    return uniqueFilename;
}

@end

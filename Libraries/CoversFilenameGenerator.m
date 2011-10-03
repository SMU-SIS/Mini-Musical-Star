//
//  CoversFilenameGenerator.m
//  MiniMusicalStar
//
//  Created by Tommi on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoversFilenameGenerator.h"

#import <CommonCrypto/CommonDigest.h>

@implementation CoversFilenameGenerator

//generate md5 hash from data
+(NSString *) returnMD5HashOfData:(NSData*)aData 
{
    //const char *concat_str = [CC_MD5_DIGEST_LENGTH];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(aData.bytes, aData.length, result);
    NSMutableString *hash = [NSMutableString string];
    
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    
    return [hash lowercaseString];
}

@end

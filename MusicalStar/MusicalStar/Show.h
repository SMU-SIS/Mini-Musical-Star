//
//  Show.h
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Show : NSObject {
    NSDictionary *data;
}

-(Show *)initWithPropertyListFile: (NSString *)pListFilePath;

@end

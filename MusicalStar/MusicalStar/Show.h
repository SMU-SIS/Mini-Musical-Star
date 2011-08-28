//
//  Show.h
//  MusicalStar
//
//  Created by Jun Kit Lee on 28/8/11.
//  Copyright 2011 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Show : NSObject {

}

@property (retain, nonatomic) NSDictionary *data;
@property (retain, nonatomic) NSArray *scenes;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *author;
@property (retain, nonatomic) UIImage *coverPhoto;
@property (retain, nonatomic) NSDate *createdDate;

-(Show *)initWithPropertyListFile: (NSString *)pListFilePath;


@end

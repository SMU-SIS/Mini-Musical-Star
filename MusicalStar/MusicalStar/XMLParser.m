//
//  XMLParser.m
//  MusicalStar
//
//  Created by Adrian on 24/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)parseShow
{
    NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"show" ofType:@"xml"];
    NSLog(@"%@",xmlFilePath);
    NSURL *xmlURL = [NSURL fileURLWithPath:xmlFilePath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [parser setDelegate:self];
    [parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"element is %@\n", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSLog(@"value is %@",string);
}

@end

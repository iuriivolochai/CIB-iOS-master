//
//  AvailabilityXMLParser.m
//  chatApp4
//
//  Created by asaf on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AvailabilityXMLParser.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation AvailabilityXMLParser
@synthesize avail;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if(!currentElementValue)
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
}

-(void) dealloc{
	if (currentElementValue){
		[currentElementValue release];
	}
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (!currentElementValue){
		DDLogError(@"Empty value for field %@", elementName);
		return;
	}
	if ([elementName isEqualToString:@"availability"]){
		if ([currentElementValue length] != 0){
			avail = [currentElementValue isEqualToString:@"true"];
		}
	}
	[currentElementValue release];
	currentElementValue = nil;
}

@end

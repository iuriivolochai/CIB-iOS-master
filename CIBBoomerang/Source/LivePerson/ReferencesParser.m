//
//  ReferencesParser.m
//  chatApp4
//
//  Created by asaf on 6/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ReferencesParser.h"


@implementation ReferencesParser
@synthesize chatRequest;
@synthesize chatAvailability;

-(void) dealloc{
	[chatRequest release];
	[chatAvailability release];
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	if ([elementName isEqualToString:@"link"]){
		NSString* href = [attributeDict objectForKey:@"href"];
		NSString* rel = [attributeDict objectForKey:@"rel"];
		if ([rel isEqualToString:@"chat-availability"]) {
			chatAvailability = [href retain];
		} else if ([rel isEqualToString:@"chat-request"]) {
			chatRequest = [href retain];
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName{
}


@end

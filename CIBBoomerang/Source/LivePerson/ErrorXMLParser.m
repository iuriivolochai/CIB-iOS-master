//
//  ErrorXMLParser.m
//  chatApp4
//
//  Created by asaf on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ErrorXMLParser.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation ErrorXMLParser

@synthesize message, errCode, time, reason;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	if(!currentElementValue)
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
}
 
-(void) dealloc{
	if (message){
		[message release];
	}
	if (time){
		[time release];
	}
	if (reason){
		[reason release];
	}
	if (currentElementValue){
		[currentElementValue release];
	}
	[super dealloc];
}
	
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	
	if([elementName isEqualToString:@"error"]){   
		return;
	}

	if (!currentElementValue){
		DDLogError(@"Empty value for field %@", elementName);
	}
	if ([elementName isEqualToString:@"message"]){
		if ([currentElementValue length] != 0){
			self.message = [NSString stringWithString:currentElementValue];
		}
	}
	if ([elementName isEqualToString:@"reason"]){
		if ([currentElementValue length] != 0){
			self.reason = [NSString stringWithString:currentElementValue];
			if (!message){
				self.message = reason;
			}
		}
	}
	else if ([elementName isEqualToString:@"time"]){
		self.time = [NSString stringWithString:currentElementValue];
	}
	else if ([elementName isEqualToString:@"internalCode"]){
		errCode = [currentElementValue intValue];
	}
	[currentElementValue release];
	currentElementValue = nil;
}

@end

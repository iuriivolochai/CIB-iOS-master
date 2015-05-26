//
//  EventsXMLParser.m
//  chatApp4
//
//  Created by asaf on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EventsXMLParser.h"
#import "chatApp4Message.h"

@implementation EventsXMLParser

@synthesize link, events, inChat, error, errorLine, errCode, chatEnded;

- (id) init{
    self = [super init];
    
	if ([super init]) {
		error = NO;
		_state = none;
	}
	return self;
}

- (void) dealloc{
	if (events){
		[events release];
	}
	if (link){
		[link release];
	}
	if (errorLine){
		[errorLine release];
	}
	if (currentElementValue){
		[currentElementValue release];
	}
	[super dealloc];
}
 

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"events"]) {
		//Initialize the array.
		if (events){
			[events release];
		}
		if (event){
			[event release];
			event = nil;
		}
		events = [[NSMutableArray alloc] init];
	}
	else if([elementName isEqualToString:@"error"]) {
		error = YES;
	}
	else if([elementName isEqualToString:@"link"]) {
		self.link = [attributeDict objectForKey:@"href"];
	}
	else if([elementName isEqualToString:@"event"]) {
		if([[attributeDict objectForKey:@"type"] isEqualToString:@"line"]) {
			event = [[chatApp4Message alloc] init];
			event._id = [attributeDict objectForKey:@"id"];
			_state = line;
		}
		else if([[attributeDict objectForKey:@"type"] isEqualToString:@"state"]) {
			_state = state;
		}
	}
}
				
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
		
	if(!currentElementValue)
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	

	if([elementName isEqualToString:@"events"]){
		return;
	}
	
	if ([elementName isEqualToString:@"error"]){
		return;
	}

	if ([elementName isEqualToString:@"link"]){
		return;
	}

	if ([elementName isEqualToString:@"event"]){
		if (event){
			[events addObject:event];
			[event release];
			event = nil;
		}
		return;
	}
	
	if (error){
		if ([elementName isEqualToString:@"message"]){
			self.errorLine = [NSString stringWithString:currentElementValue];
		}
		else if ([elementName isEqualToString:@"internalCode"]){
			errCode = [currentElementValue intValue];
		}
	}
	else if (_state == line){
		if ([elementName isEqualToString:@"text"]){	
			event.line = [NSString stringWithString:currentElementValue];
		}
		else if ([elementName isEqualToString:@"source"]){
			if ([currentElementValue isEqualToString:@"system"]){
				event.system = YES;
				
			}
			else if ([currentElementValue isEqualToString:@"agent"]){
				event.system = NO;
				event.visitor = NO;
			}
			else if ([currentElementValue isEqualToString:@"visitor"]){
				event.system = NO;
				event.visitor = YES;
			}
			
		}
		else if ([elementName isEqualToString:@"by"]){
			event.by = [NSString stringWithString:currentElementValue];
		}
	}
	else if (_state == state){
		if ([elementName isEqualToString:@"state"]){
			if ([currentElementValue isEqualToString:@"chatting"]){
				inChat = YES;
				chatEnded = NO;
			}
			else if ([currentElementValue isEqualToString:@"waiting"]){
				chatEnded = NO;
			}			
			else if ([currentElementValue isEqualToString:@"ended"]){
				inChat = NO;
				chatEnded = YES;
			}
		}
	}
	[currentElementValue release];
	currentElementValue = nil;
}
				
@end

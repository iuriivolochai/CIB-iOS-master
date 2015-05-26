//
//  InfoXMLParser.m
//  chatApp4
//
//  Created by asaf on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InfoXMLParser.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation InfoXMLParser
@synthesize state, agentName, agentTyping, visitorID, visitorName, visitorTyping, startTime, lastUpdate, chatTimeOut;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
	if(!currentElementValue)
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
}

-(void) dealloc{
	if(state){
		[state release];
	}
	if (agentName){
		[agentName release];
	};
	if (startTime){
		[startTime release];
	}
	if (lastUpdate){
		[lastUpdate release];
	}
	if (visitorID){
		[visitorID release];
	}
	if (visitorName){
		[visitorName release];
	}
	if (currentElementValue){
		[currentElementValue release];
	}
	[super dealloc];
}	
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	
	if([elementName isEqualToString:@"info"]){   
		if (currentElementValue){
			[currentElementValue release];
			currentElementValue = nil;
		}
		return;
	}
	
	if ([elementName isEqualToString:@"state"]){
		self.state = [NSString stringWithString:currentElementValue];
	}
	else if ([elementName isEqualToString:@"agentName"]){
		self.agentName = [NSString stringWithString:currentElementValue];
	}
	else if ([elementName isEqualToString:@"startTime"]){
		self.startTime = [NSString stringWithString:currentElementValue];
	}
	else if ([elementName isEqualToString:@"lastUpdate"]){	
		self.lastUpdate = [NSString stringWithString:currentElementValue];
	}
	else if ([elementName isEqualToString:@"chatTimeout"]){
		chatTimeOut = [currentElementValue intValue];
	}
	else if ([elementName isEqualToString:@"visitorId"]){
		self.visitorID = [NSString stringWithString:currentElementValue];
	}
	
	else if ([elementName isEqualToString:@"agentTyping"]){
		DDLogVerbose(@"Agent typing is :%@", currentElementValue);
		agentTyping = [currentElementValue isEqualToString:@"typing"] ? YES : NO;
	}
	else if ([elementName isEqualToString:@"visitorTyping"]){
		visitorTyping = [currentElementValue isEqualToString:@"typing"] ? YES : NO;
	}
	else if ([elementName isEqualToString:@"visitorName"]){
		self.visitorName = [NSString stringWithString:currentElementValue];
	}	
	[currentElementValue release];
	currentElementValue = nil;
}
@end 

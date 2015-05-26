//
//  EventsXMLParser.h
//  chatApp4
//
//  Created by asaf on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
	{
		none,
		line,
		state
	}states;

@class chatApp4Message;
@interface EventsXMLParser : NSObject<NSXMLParserDelegate> {
	NSMutableArray* events;
	NSString* link;
	chatApp4Message* event;
	states _state; 
	NSMutableString* currentElementValue;
	Boolean inChat;
	Boolean chatEnded;
	Boolean error;
	NSString* errorLine;
	NSInteger errCode;
}
@property (nonatomic, retain) NSMutableArray* events;
@property (nonatomic, retain) NSString* link;
@property (nonatomic, readwrite) Boolean inChat;
@property (nonatomic, readwrite) Boolean chatEnded;
@property (nonatomic, readwrite) Boolean error;
@property (nonatomic, retain) NSString* errorLine;
@property (nonatomic, readwrite) NSInteger errCode;
@end

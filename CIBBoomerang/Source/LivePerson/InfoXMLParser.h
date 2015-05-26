//
//  InfoXMLParser.h
//  chatApp4
//
//  Created by asaf on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InfoXMLParser : NSObject <NSXMLParserDelegate>{
	NSString* state;
	NSString* agentName;
	NSString* startTime;
	NSString* lastUpdate;
	NSInteger chatTimeOut;   
	NSString* visitorID;
	Boolean   agentTyping;
	Boolean   visitorTyping;
	NSString* visitorName;
	NSMutableString* currentElementValue;
}
@property (nonatomic, retain)  NSString* state;
@property (nonatomic, retain)  NSString* agentName;
@property (nonatomic, retain)  NSString* startTime;
@property (nonatomic, retain)  NSString* lastUpdate;
@property (nonatomic, readonly)   NSInteger chatTimeOut;
@property (nonatomic, retain)  NSString* visitorID;
@property (nonatomic, readonly)     Boolean agentTyping;
@property (nonatomic, readonly)     Boolean visitorTyping;
@property (nonatomic, retain)  NSString* visitorName;


@end

//
//  chatApp4Moder.h
//  chatApp4
//
//  Created by asaf on 11/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InfoXMLParser;
typedef enum{
	chatStarted,
	chatRequested,
chatEnded} chatStates;


@interface chatApp4Model : NSObject { 
	NSMutableArray* chatLinesHistory;
	NSMutableDictionary* chatTranslatedLines; 
	NSMutableDictionary* chatVisitorTranslatedLines;
	NSString * connection;
	NSString * siteid;
	NSString* skill;
	NSString * uri;
	NSString* appKey;
	NSString* appKeyHeader;
	NSString* ver;
	NSString* location;
	NSString* chatRequest;
	NSString* agentAvailability;
	NSString* lastEvents;
	NSString * lastError;
	NSString * visitorName;
	NSThread *   myThread;
	NSString* lang;
	Boolean translate;
	chatStates    chatState;
	Boolean chatStopRequested;
	InfoXMLParser* info;
	NSString* visitorID;
}
@property (nonatomic, retain) NSString * siteid;
@property (nonatomic, retain) NSString * skill;
@property (nonatomic,retain) NSString* uri;
@property (nonatomic, readonly) chatStates chatState;
@property (nonatomic, retain) InfoXMLParser* info;
@property (nonatomic, retain) NSString* lastError;
@property (nonatomic, retain) NSString* lang;
@property (nonatomic) Boolean translate;
@property (nonatomic, retain) NSString* visitorID;

- (NSInteger) toggleChat: (NSString *) vn;
- (NSInteger) stopChat: (Boolean) clearChatLines;
- (NSInteger) startChat:(NSString*) vn;
- (NSInteger) sendLine: (NSString*) line;
- (NSInteger) setTyping: (Boolean) typing;
- (void) addLine: (NSString*) newLine; 
- (NSMutableArray *) getLines;
- (NSMutableDictionary *) getTranslatedLines;
- (NSMutableDictionary *) getVisitorTranslatedLines;
- (Boolean) isAvailableForChat:(NSString*) agent;
- (Boolean) isAvailableForChat:(NSString*) _skill maxWaitTime:(int)maxWaitTime queue:(NSString*) queue;
- (Boolean) sendAvailableForChat:(NSString*) req;
- (id) initialize;

/* the following are not supposed to be called from outside the model */
- (void) clearChat;
- (void) chatStopped;
- (NSMutableArray *) getEvents;
- (NSData *) sendPostRequest: (NSString*) url body: (NSString* ) _body response:(NSHTTPURLResponse **) res error:(NSError**) error;
- (NSData *) sendPutRequest: (NSString*) url body: (NSString* ) _body response:(NSHTTPURLResponse **) res error:(NSError**) error;
- (NSData *) sendGetRequest: (NSString*) url response:(NSHTTPURLResponse **) res error:(NSError**) error;
-(NSData*) internalSend:(NSMutableURLRequest*) req response:(NSHTTPURLResponse **) res error:(NSError**) error;
- (void)  pollingThread: (id)obj;
- (NSMutableArray*) translateLines: (NSMutableArray*) lines langPair: (NSString*) langpair;
- (void) translateEvents: (NSMutableArray*) events;
-(void) readVisitorID;
-(void) getInfo;
-(NSInteger) getURLs;
-(void) printDataToLog:(NSData*) data;
@end

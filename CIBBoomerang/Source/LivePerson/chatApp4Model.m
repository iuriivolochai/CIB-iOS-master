//
//  chatApp4Moder.m
//  chatApp4
//
//  Created by asaf on 11/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "chatApp4Model.h"
#import "chatApp4Message.h"
#import "EventsXMLParser.h"
#import "InfoXMLParser.h"
#import "ErrorXMLParser.h"
#import "ReferencesParser.h"
#import "AvailabilityXMLParser.h"
#import "SyncSender.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation chatApp4Model
@synthesize siteid, skill, uri, chatState, info, lastError, translate, lang, visitorID;

- (id) initialize{
	self = [super init];
	if (self){
		self.lastError = nil;
		chatState = chatEnded;
		appKey=@"";  //put your own app key here
		appKeyHeader = [[NSString stringWithFormat: @"LivePerson appKey=%@", appKey] retain];
		ver=@"1";
		chatStopRequested = NO;
		info = [[InfoXMLParser alloc] init];
	}
	return self;
}

- (void) dealloc{
	if (chatRequest){
		[chatRequest release];
	}
	
	if (agentAvailability){
		[agentAvailability release];
	}
	
	[chatLinesHistory release];
	[chatTranslatedLines release];
	[chatVisitorTranslatedLines release];
	if (info){
		[info release];
	}
	if (lastEvents){
		[lastEvents release];
		lastEvents = nil;
	}
	[appKeyHeader release];
	if(siteid){
		[siteid release];
	}
	if (skill){
		[skill release];
	}
	if(uri){
		[uri release];
	}
	if (lastError){
		[lastError release];
	}
	if (lang){
		[lang release];
	}
	if (visitorID){
		[visitorID release];
	}
	
	[super dealloc];
}

- (void) addLine: (NSString*) newline{
	if (chatState == chatEnded){
		return;
	}
	
	chatApp4Message* msg = [[chatApp4Message alloc] init];
	msg.by = @"IPhone";
	msg.line = newline;
	msg.system = YES;
	
	[chatLinesHistory addObject:msg];
	[msg release];
}


- (NSMutableArray *) getLines{
	return chatLinesHistory ;
}

- (NSMutableDictionary *) getTranslatedLines{
	return chatTranslatedLines ;
}

- (NSMutableDictionary *) getVisitorTranslatedLines{
	return chatVisitorTranslatedLines ;
}

- (NSInteger) toggleChat: (NSString*) vn{
	if (chatState != chatEnded){
		DDLogVerbose(@"Stopping Chat");
		return [self stopChat:NO];
	}
	else {
		return [self startChat:vn];
	}
}

-(NSInteger) startChat:(NSString*) vn{
	if (!visitorID){
		[self readVisitorID];
	}
	self.lastError = nil;

	if (lastEvents){
		[lastEvents release];
		lastEvents = nil;
	}	
	
	NSInteger ret = [self getURLs];
	if (ret){
		return ret;
	}
	
	DDLogVerbose(@"Starting chat");
	chatStopRequested = NO;
	[self clearChat];	
	chatLinesHistory = 	[NSMutableArray array];
	[chatLinesHistory retain];

	//call the rest
	NSString* req = [NSString stringWithFormat:@"%@?appKey=%@&v=%@", chatRequest, appKey , ver];	
	NSError* error;
	NSHTTPURLResponse* res;
	NSString * body = @"<request>";
	if (skill && [skill length] > 0){
		body = [NSString stringWithFormat:@"%@<skill>%@</skill>" , body, skill];
	}
	if (visitorID && [visitorID length] > 0){
		body = [NSString stringWithFormat:@"%@<visitorId>%@</visitorId>", body, visitorID];
	}
	
	body = [NSString stringWithFormat:@"%@<userAgent>IPhone</userAgent> </request>",body];
	
		
	NSData* data = [self sendPostRequest:req body:body response: &res error:&error];
//	[req release];
//	[body release];
	if (!data){
		if (error) {
			self.lastError = [NSString stringWithString: [error localizedDescription]];
		}
		else{
			self.lastError = @"UNKNOWN ERROR";
		}
		return -1;
	}
	
	NSInteger status = [res statusCode];
	if (status != 201){
		NSString* res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		DDLogError(@"Error message from start chat is: %@", res);
		NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
		if (parser){
			ErrorXMLParser* errorParser = [[ErrorXMLParser alloc] init];
		
			[parser setDelegate: errorParser];
			if ([parser parse]){
				self.lastError = [NSString stringWithString: errorParser.message ? errorParser.message : @"Unkown Error"];
			}
			[parser release];
			[errorParser release];
		}
		self.lastError = [NSString stringWithFormat:@"%@ (%@)", lastError, [NSHTTPURLResponse localizedStringForStatusCode:status]];
		[res release];
		return status;
	}
	if (location){
		[location release];
		location = nil;
	}
	
	location = [[res allHeaderFields] objectForKey:@"Location"];
	[location retain];
	DDLogVerbose(@"New chat started:%@",location);
	
	chatState = chatRequested;
	myThread = [[NSThread alloc] initWithTarget: self selector:@selector(pollingThread:) object:nil];
	[myThread start];
	visitorName = [NSString stringWithString: vn];
	
//set visitor name
/*
	req = [NSString stringWithFormat:@"%@/info/visitorName?appKey=%@&v=%@",location,appKey,ver];
	body =	[NSString stringWithFormat:@"<visitorName>%@</visitorName>", vn];
	response = [self sendPutRequest:req body:body response: &res error:&error];
	NSLog([NSString stringWithFormat:@"Response is:%@ status is:%d",response, [res statusCode]]);
*/
	
	return 201;//created
}
-(NSInteger) getURLs{
	if (chatRequest){
		[chatRequest release];
		chatRequest = nil;
	}
	if (agentAvailability){
		[agentAvailability release];
		agentAvailability = nil;
	}
	
	NSString* req = [NSString stringWithFormat:@"%@/api/account/%@?v=%@&appKey=%@",uri,siteid,ver,appKey];
	NSError* error;
	NSHTTPURLResponse* res;
	NSData* data = [self sendGetRequest:req response: &res error:&error];
	if (!data){
		if (error) {
			self.lastError = [NSString stringWithString: [error localizedDescription]];
		}
		else{
			self.lastError = @"UNKNOWN ERROR";
		}
		
		return -1;
	}
	
	
	NSInteger status;
	if (!res){
		status = [error code];
	}
	else{
		status = [res statusCode];
	}
	if (status != 200){
		NSString* res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		DDLogError(@"Error message from getURLs is: %@", res);
		NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
		if (parser){
			ErrorXMLParser* errorParser = [[ErrorXMLParser alloc] init];
			
			[parser setDelegate: errorParser];
			if ([parser parse]){
				self.lastError = [NSString stringWithString: errorParser.message ? errorParser.message : @"Unkown Error"];
			}
			[parser release];
			[errorParser release];
		}
		self.lastError = [NSString stringWithFormat:@"%@ (%@)", lastError, [NSHTTPURLResponse localizedStringForStatusCode:status]];
		[res release];
		return status;
	}
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
	
	if (!parser){
		return -1;
	}
	ReferencesParser* referencesParser = [[ReferencesParser alloc] init];
	
	[parser setDelegate: referencesParser];
	if (![parser parse]){
		[referencesParser release];
		[parser release];
		return -1;
	}
	chatRequest = [referencesParser.chatRequest retain];
	agentAvailability = [referencesParser.chatAvailability retain];

	[referencesParser release];
	[parser release];
	return 0;
}
- (NSInteger) stopChat : (Boolean) clearChatLines{
	self.lastError = nil;
	
	if (chatStopRequested){
		return -1;
	}
	
	chatStopRequested = true;
	self.lastError = @"OK";

	NSString* req = [NSString stringWithFormat:@"%@%@%@%@%@",location, @"/events?appKey=" , appKey , @"&v=" , ver];	
	NSError* error;
	NSHTTPURLResponse* res;
	NSString* body = @"<event type=\"state\"><state>ended</state></event>";
	NSData* data = [self sendPostRequest:req body:body response: &res error:&error];
		
//	[req release];
	if (!data){
		self.lastError = @"UnknowError";
	}
	else {
		NSInteger status = [res statusCode];
		if (status != 201){
			self.lastError = [NSHTTPURLResponse localizedStringForStatusCode:status];
		}
	}
//	[self addLine:@"Chat Ended"];
	if (clearChatLines){
		[self clearChat];
	}
		
	[self chatStopped];
	
	return 201;
}
- (void) clearChat{
	self.lastError = nil;
	if (chatLinesHistory){
		[chatLinesHistory release];
		chatLinesHistory = nil;
	}
	if (chatTranslatedLines){
		[chatTranslatedLines release];
		chatTranslatedLines = nil;
	}
	if (chatVisitorTranslatedLines){
		[chatVisitorTranslatedLines release];
		chatVisitorTranslatedLines = nil;
	}
	
}

-(void) chatStopped{
	self.lastError = nil;
	if (chatState == chatEnded){
		return;
	}

	if (info){
		[info release];
		info = nil;
	}
	chatStopRequested = true;
	chatState = chatEnded;
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"newEvents" object:self];
	if (lastEvents){
		[lastEvents release];
		lastEvents = nil;
	}
	if (location){
		[location release];
		location = nil;
	}

	NSMutableDictionary* threadDict = [myThread threadDictionary];
	
    [threadDict setValue:[NSNumber numberWithBool:YES] forKey:@"ThreadShouldExitNow"];
	[myThread release];
	myThread = nil;	
	
//	[controller chatStarted:NO];
}
- (Boolean) isAvailableForChat:(NSString*) agent{
	self.lastError = nil;
	
	NSInteger ret = [self getURLs];
	if (ret){
		return false;
	}
	
	NSString* req = [NSString stringWithFormat:@"%@?appKey=%@&v=%@&agent=%@" , agentAvailability ,appKey , ver, agent];	
	return [self sendAvailableForChat:req];
}
- (Boolean) isAvailableForChat:(NSString*) _skill maxWaitTime:(int)maxWaitTime queue:(NSString*) queue{
	self.lastError = nil;
	
	NSInteger ret = [self getURLs];
	if (ret){
		return false;
	}
	
	NSMutableString* req = [NSMutableString stringWithFormat:@"%@?appKey=%@&v=%@" , agentAvailability ,appKey , ver];
	if (_skill && [_skill length]){
		[req appendFormat:@"&skill=%@",_skill];
	}
	if (queue && [queue length]){
		[req appendFormat:@"&serviceQueue=%@",queue];
	}
	if (maxWaitTime!=-1){
		[req appendFormat:@"&maxWaitTime=%d",maxWaitTime];
	}
	return [self sendAvailableForChat:req];
}

- (Boolean) sendAvailableForChat:(NSString*) req{
	NSError* error;
	NSHTTPURLResponse* res;
	NSData* data = [self sendGetRequest:req response: &res error:&error];

//	[req release];
	if (!data){
		if (error) {
			self.lastError = [NSString stringWithString: [error localizedDescription]];
		}
		else{
			self.lastError = @"UNKNOWN ERROR";
		}
		return false;
	}
	
	NSInteger status = [res statusCode];
	if (status != 200){
		NSString* res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		DDLogError(@"Error message from is available is: %@", res);
		NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
		if (parser){
			ErrorXMLParser* errorParser = [[ErrorXMLParser alloc] init];
			
			[parser setDelegate: errorParser];
			if ([parser parse]){
				self.lastError = [NSString stringWithString: errorParser.message ? errorParser.message : @"Unkown Error"];
			}
			[parser release];
			[errorParser release];
		}
		self.lastError = [NSString stringWithFormat:@"%@ (%@)", lastError, [NSHTTPURLResponse localizedStringForStatusCode:status]];
		[res release];
		return false;
	}
	
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
	
	if (!parser){
		return false;
	}
	AvailabilityXMLParser* availParser = [[AvailabilityXMLParser alloc] init];
	
	[parser setDelegate: availParser];
	if (![parser parse]){
		[availParser release];
		[parser release];
		return false;
	}

	Boolean avail = availParser.avail;
	[availParser release];
	[parser release];
	
	return avail;

}

- (NSMutableArray*) getEvents{
	self.lastError = nil;
	
	if (chatState == chatEnded){
		return nil;
	}
	NSString* req;
	if (!lastEvents){
		req = [NSString stringWithFormat:@"%@%@%@%@%@",location, @"/events?appKey=" , appKey , @"&v=" , ver];
	}
	else {
		req = lastEvents;
	}
	DDLogVerbose(@"Get new Events:%@" , req);
	NSHTTPURLResponse* res;
	NSError* error;
	NSData* data = [self sendGetRequest:req response:&res error:&error];
	
	if (!data){
		if (!res && error){
			DDLogError(@"Error in get events - %@",[error localizedDescription]);
		}
		else {
			[self chatStopped];
		}
		DDLogVerbose(@"nil response");
		
		return nil;
	}
	
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];

	if (!parser){
		[self chatStopped];
		DDLogVerbose(@"Parser is nil");
		return nil;
	}
	EventsXMLParser* eventsParser = [[EventsXMLParser alloc] init];

	[parser setDelegate: eventsParser];
	if (![parser parse] || eventsParser.error){
		if (eventsParser.error){
			[self chatStopped];
			DDLogError(@"Error from get events: %@", eventsParser.errorLine);
		}
		else {
			DDLogVerbose(@"Unable to parse the events reply");
		}
		[eventsParser release];
		[parser release];
		return nil;
	}

	NSMutableArray* x = [NSMutableArray arrayWithArray: eventsParser.events];

	if (lastEvents){
		[lastEvents release];
	}
	lastEvents = [NSString stringWithFormat:@"%@&appKey=%@&v=%@", eventsParser.link, appKey, ver];
	if ([uri hasSuffix: @"192.168.60.4"]){
		lastEvents = [lastEvents stringByReplacingOccurrencesOfString:@"lpwebdemo.liveperson.com" withString:@"192.168.60.4"];
	}
	[lastEvents retain];
	if (eventsParser.chatEnded){
		[self chatStopped];
	}
	else if (eventsParser.inChat){
		chatState = chatStarted;
	}
	
	[eventsParser release];
	[parser release];
	return [[x retain] autorelease];
}

-(void) getInfo{
	if (chatState == chatEnded){
		return;
	}

	self.lastError = nil;
	
	NSString* strUrl = [NSString stringWithFormat:@"%@/info?appKey=%@&v=%@", location, appKey, ver];
	DDLogVerbose(@"GetInfo %@" , strUrl);

	NSHTTPURLResponse* res;
	NSError* error;
	NSData* data = [self sendGetRequest:strUrl response:&res error:&error];
//	[strUrl release];
	
	if (!data){
		if (!res && error){
			DDLogError(@"Error in get info - %@",[error localizedDescription]);
		}
	}
	
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
	
	if (!parser){
		return;
	}
	if (!info){
		info = [[InfoXMLParser alloc] init];
	}
	[parser setDelegate: info];
	[parser parse];
	[parser release];
	if (info.visitorID && ![info.visitorID isEqual:visitorID]) {
		self.visitorID = info.visitorID;
		NSString* errString;
		NSArray *values=[NSArray arrayWithObjects: self.visitorID, nil];
		NSArray *keys = [NSArray arrayWithObjects: @"visitorID",nil];
		NSDictionary* settings = [NSDictionary dictionaryWithObjects: values forKeys:keys];
		NSData *serializedSettings=[NSPropertyListSerialization dataFromPropertyList:settings format:NSPropertyListXMLFormat_v1_0  errorDescription:&errString];   
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);   
		NSString *documentsDirectory = [paths objectAtIndex:0];   
		NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"visitorID.xml"];   
		[serializedSettings writeToFile:appFile atomically:NO];		
	}
}	
	
- (NSInteger) setTyping: (Boolean) typing{
	self.lastError = @"OK";
	return 200;
}
- (NSInteger) sendLine: (NSString*) line{
	if (chatState == chatEnded){
		return -1;
	}

	self.lastError = nil;

	if (translate){
		NSMutableArray* lines = [[NSMutableArray alloc] initWithCapacity:1];
		[lines addObject:line];
		NSString* langPair = [NSString stringWithFormat:@"%@|en",lang];
		NSMutableArray* tr = [self translateLines:lines langPair:langPair];
		NSString* val = line;
		line = [NSString stringWithFormat:@"(T)%@", [tr objectAtIndex:0]];
		[lines release];
		if (!chatVisitorTranslatedLines){
			chatVisitorTranslatedLines = [[[NSMutableDictionary alloc] initWithCapacity:30] retain];
		}
		[chatVisitorTranslatedLines setObject:val forKey:line];
	}
	NSString* req = [NSString stringWithFormat:@"%@%@%@%@%@",location, @"/events?appKey=" , appKey , @"&v=" , ver];	
	NSError* error;
	NSHTTPURLResponse* res;
	NSString* line1 = [line stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	line1 = [line1 stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
	line1 = [line1 stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
	NSString* body = [NSString stringWithFormat:@"<event type=\"line\"><text>%@</text></event>" , line1];
	NSData* data = [self sendPostRequest:req body:body response: &res error:&error];
//	[req release];
//	[body release];
	if (!data){
		self.lastError = @"UnknowError";
		return -1;
	}
	else {
		NSInteger status = [res statusCode];
		if (status != 201){
			self.lastError = [NSHTTPURLResponse localizedStringForStatusCode:status];
			return status;
		}
	}
	return 201;
}

- (void)pollingThread: (id) obj{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL exitNow = NO;
    // Add the exitNow BOOL to the thread dictionary.
	
    NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];
	
    [threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ThreadShouldExitNow"];
    while (!exitNow)
    {
		NSMutableArray* events = [self getEvents];
		if (events){
			[self translateEvents:events];
			for (chatApp4Message * m in events){
				[chatLinesHistory addObject:m];
			}
		}			
		[self getInfo];
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"newEvents" object:self];
		[pool release];
		[NSThread sleepForTimeInterval:4];
        exitNow = [[threadDict valueForKey:@"ThreadShouldExitNow"] boolValue];
		pool = [[NSAutoreleasePool alloc] init];

    }
	DDLogVerbose( @"polling thread terminated");

	[pool release];
}

- (NSData *) sendPostRequest: (NSString*) url body: (NSString* ) _body response:(NSHTTPURLResponse **) res error:(NSError**) error{
	NSURL * nsurl = [NSURL URLWithString:url];
	NSMutableURLRequest* nsReq =  [NSMutableURLRequest requestWithURL: nsurl];
//	[nsurl release];
	[nsReq setTimeoutInterval:10];
	NSData* body = [_body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	[nsReq setValue:@"application/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[nsReq setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
	[nsReq setValue:appKeyHeader forHTTPHeaderField:@"Authorization"];	
	[nsReq setHTTPMethod:@"POST"];
	
	NSString* bodyLen = [NSString stringWithFormat:@"%d", [body length]];
	
	[nsReq setHTTPBody:body]; 
	[nsReq setValue:bodyLen forHTTPHeaderField:@"Content-Length"];
	DDLogVerbose(@"About to send POST request:%@",nsReq);

	NSData * data = [self internalSend:nsReq response: res error: error];
	return data;
}

- (NSData *) sendPutRequest: (NSString*) url body: (NSString* ) _body response:(NSHTTPURLResponse **) res error:(NSError**) error{
	NSURL * nsurl = [NSURL URLWithString:url];
	NSMutableURLRequest* nsReq =  [NSMutableURLRequest requestWithURL: nsurl];
//	[nsurl release];
	[nsReq setTimeoutInterval:10];
	NSData* body = [_body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	[nsReq setValue:@"application/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[nsReq setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
	[nsReq setValue:@"PUT" forHTTPHeaderField:@"X-HTTP-Method-Override"];
	[nsReq setValue:appKeyHeader forHTTPHeaderField:@"Authorization"];
	
	[nsReq setHTTPMethod:@"POST"];
	
	NSString* bodyLen = [NSString stringWithFormat:@"%d", [body length]];
	
	[nsReq setHTTPBody:body]; 
	[nsReq setValue:bodyLen forHTTPHeaderField:@"Content-Length"];

	DDLogVerbose(@"About to send PUT request: %@ (%@)",url,_body);
	
	NSData * data = [self internalSend:nsReq response: res error: error];
	return data;
}

- (NSData *) sendGetRequest: (NSString*) url response:(NSHTTPURLResponse **) res error:(NSError**) error{
	NSURL * nsurl = [NSURL URLWithString:url];
	NSMutableURLRequest* nsReq =  [NSMutableURLRequest requestWithURL: nsurl];
	[nsReq setTimeoutInterval:10];
	[nsReq setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
	[nsReq setValue:appKeyHeader forHTTPHeaderField:@"Authorization"];
	[nsReq setHTTPMethod:@"GET"];
	DDLogVerbose(@"About to send GET request: %@",nsReq);
	
	NSData * data = [self internalSend:nsReq response: res error: error];
	return data;
}

-(NSData*) internalSend:(NSMutableURLRequest*) req response:(NSHTTPURLResponse **) res error:(NSError**) error{
    SyncSender* sender = [[SyncSender alloc] initWithRequest:req];
	
	NSData* data = [sender run:res error:error timeout:20];
	[sender release];
    [self printDataToLog:data];
    return data;
}

- (void) translateEvents: (NSMutableArray*) events{
	if (!translate || ![events count]){
		return;
	}
	NSMutableArray* ids = [[NSMutableArray alloc] initWithCapacity:10];
	NSMutableArray* lines = [[NSMutableArray alloc] initWithCapacity:10];
	for (chatApp4Message * m in events){
		if (!m.visitor){
			[ids addObject:m._id];
			[lines addObject:m.line];
		}
	}
	NSString* langpair = [NSString stringWithFormat:@"|%@",lang];
	NSMutableArray* translatedLines = [self translateLines: lines langPair:langpair];
	if (!chatTranslatedLines){
		chatTranslatedLines = [[[NSMutableDictionary alloc] initWithCapacity:30] retain];
	}
	int id=0;
	for (NSString* line in translatedLines){
		[chatTranslatedLines setObject:line forKey:[ids objectAtIndex:id++]];
	}
	
	[ids release];
	[lines release];
}

- (NSMutableArray*) translateLines: (NSMutableArray*) lines langPair: (NSString*) langpair{
	if (!translate){
		return nil;
	}
	NSString* req = [NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&langpair=%@", langpair];
	for (NSString* line in lines){
		req = [NSString stringWithFormat:@"%@&q=%@",req,line];
	}
	req = [req stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSURL * nsurl = [NSURL URLWithString:req];
	NSHTTPURLResponse * res;
	NSError* error;
	NSMutableURLRequest* nsReq =  [NSMutableURLRequest requestWithURL: nsurl];
	//	[nsurl release];
	[nsReq setTimeoutInterval:10];
	[nsReq setValue:@"http://www.liveperson.com" forHTTPHeaderField:@"Referrer"];
	[nsReq setHTTPMethod:@"GET"];
	
	NSData * data = [NSURLConnection sendSynchronousRequest:nsReq returningResponse: &res error: &error];
	NSString* ress = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSString* origRes = ress;
	NSRange find = [ress rangeOfString:@"\"translatedText\":"];
	NSRange subRange;
	NSMutableArray* ret = [[[NSMutableArray alloc] initWithCapacity:[lines count]] autorelease];
	while (find.location != NSNotFound){
		ress = [ress substringFromIndex:find.location + find.length+1];
		find = [ress rangeOfString:@"\""];
		if (find.location != NSNotFound){
			subRange.location = 0;
			subRange.length = find.location;
			NSString* trans = [ress substringWithRange:subRange];
			DDLogVerbose(@"(he)%@",trans);
			[ret addObject:trans];
		}
		find = [ress rangeOfString:@"\"translatedText\":"];
	}
	[origRes release];  
	return ret;
}
-(void) readVisitorID{
	NSString * errString;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);   
	NSString *documentsDirectory = [paths objectAtIndex:0];   
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"visitorID.xml"];
	NSPropertyListFormat fmt;

	NSData* data = [NSData dataWithContentsOfFile:appFile];
	if (data){
		NSDictionary* props = [NSPropertyListSerialization propertyListFromData:data mutabilityOption: NSPropertyListImmutable format: &fmt errorDescription: &errString];
		self.visitorID = [props objectForKey: @"visitorID"];
	}
}

-(void) printDataToLog:(NSData*) data{
	NSString* prt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	DDLogVerbose(@"Result is %@",prt);
	[prt release];
}

@end

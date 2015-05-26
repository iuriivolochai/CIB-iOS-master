//
//  SyncSender.m
//  chatAgent1
//
//  Created by asaf on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncSender.h"
//#define PrintLog

@implementation SyncSender

-(id)initWithRequest:(NSURLRequest* )theRequest{
	self = [super init];
	if (self){
		req = [theRequest retain];
		ready = [[NSCondition alloc] init];
	}
	return self;
}

-(void) dealloc{
	[req release];
	[ready release];
	if (myerr){
		[myerr release];
	}
	if (myRes){
		[myRes release];
	}
	if (data){
		[data release];
	}
	[super dealloc];
}

-(NSData*) run:(NSHTTPURLResponse**) res error:(NSError**)err timeout:(int) to{
	lastByteTime = [[NSDate date] timeIntervalSince1970];
#ifdef PrintLog
	NSLog(@"About to send a message");
#endif
	NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(send:) object:nil];
	[thread setName:@"Sender Worker"];
 
	[thread start];
	while (true){
		[ready lock];
		if (finished){
			[ready unlock];
			break;
		}
		NSDate* d = [NSDate dateWithTimeIntervalSinceNow:to];
		[ready waitUntilDate:d];
		[ready unlock];
		if (finished){
			break;
		}
		if ([[NSDate date] timeIntervalSince1970] - lastByteTime> to){
			NSLog(@"Too much time to send message");
			[theConnection cancel];
			finished = true;
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:@"Request didn't finish on time" forKey:NSLocalizedDescriptionKey];
			myerr = [[NSError errorWithDomain:@"agent1" code:100 userInfo:errorDetail] retain];
		}
	}
#ifdef PrintLog
	NSLog(@"Message received");
#endif
	[theConnection release];
	[thread cancel];
	[thread release];
	if (myRes){
		*res = (NSHTTPURLResponse*)[[myRes retain] autorelease];
	}
	if (myerr && err){
		*err = [[myerr retain] autorelease];
	}
	if (data){
		return [[data retain] autorelease];
	}
	
	return nil;
}
-(void) send:(id)obj{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
#ifdef PrintLog
	NSLog(@"Start send thread");
#endif
	theConnection=[[NSURLConnection alloc] initWithRequest:req delegate:self];
	if (theConnection) {
#ifdef PrintLog
		NSLog(@"Connection Established");
#endif
		// Create the NSMutableData to hold the received data.
	// receivedData is an instance variable declared elsewhere.
		data = [[NSMutableData data] retain];
		NSDate* d = [NSDate dateWithTimeIntervalSinceNow:1]; 
		while (!finished && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:d]){
			d = [NSDate dateWithTimeIntervalSinceNow:1]; 
		}
	}
	else{
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Unable to open a connection" forKey:NSLocalizedDescriptionKey];
		myerr = [[NSError errorWithDomain:@"agent1" code:101 userInfo:errorDetail] retain];
		finished = true;
		[ready lock];
		[ready signal];
		[ready unlock];
	}
#ifdef PrintLog
	NSLog(@"Send thread out");
#endif
	[pool release];
}
	
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    [data setLength:0];
	lastByteTime = [[NSDate date] timeIntervalSince1970];
	if (myRes){
		[myRes release];
	}
	myRes = [response retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
#ifdef PrintLog
    NSLog(@"Received %d bytes of data",[d length]);
#endif
    [data appendData:d];
	lastByteTime = [[NSDate date] timeIntervalSince1970];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *) error{
    // release the connection, and the data object
    // receivedData is declared as a method instance elsewhere
    [data release];
	data = nil;
	myerr = [error retain];
	finished = true;
	[ready lock];
	[ready signal];
	[ready unlock];
    // inform the user
    NSLog(@"Connection failed! Error - %@ )(%d)[%@]",
          [error localizedDescription], [error code],error.debugDescription);	
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
	lastByteTime = [[NSDate date] timeIntervalSince1970];
#ifdef PrintLog
	NSLog(@"Succeeded! Received %d bytes of data",[data length]);
#endif	
    // release the connection, and the data object
	finished = true;
	[ready lock];
	[ready signal];
	[ready unlock];
}
- (NSURLRequest *)connection: (NSURLConnection *)inConnection
             willSendRequest: (NSURLRequest *)inRequest
            redirectResponse: (NSURLResponse *)inRedirectResponse;
{
    if (inRedirectResponse) {
        NSMutableURLRequest *r = [[req mutableCopy] autorelease]; // original request
        [r setURL: [inRequest URL]];
        return r;
    } else {
        return inRequest;
    }
}
@end

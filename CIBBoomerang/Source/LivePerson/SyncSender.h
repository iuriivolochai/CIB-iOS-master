//
//  SyncSender.h
//  chatAgent1
//
//  Created by asaf on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SyncSender : NSObject{
	NSCondition* ready;
	NSMutableData* data;
	NSURLRequest* req;
	NSTimeInterval lastByteTime;
	NSError* myerr;
	NSURLResponse* myRes;
	Boolean finished;
	NSURLConnection *theConnection;
}
-(id)initWithRequest:(NSURLRequest* )theRequest;
-(NSData*) run:(NSHTTPURLResponse**) res error:(NSError**)err timeout:(int) to;
@end

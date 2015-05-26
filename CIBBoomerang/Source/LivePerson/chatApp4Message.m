//
//  chatApp4Message.m
//  chatApp4
//
//  Created by asaf on 11/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "chatApp4Message.h"
 

@implementation chatApp4Message
@synthesize line, by, system, date, _id, visitor;

- (void) dealloc{
	if(line){
		[line release];
	}
	if (by){
		[by release];
	}
	if (date){
		[date release];
	}
	if (_id){
		[_id release];
	}
	
	[super dealloc];
}
@end

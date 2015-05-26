//
//  chatApp4Message.h
//  chatApp4
//
//  Created by asaf on 11/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface chatApp4Message : NSObject {
	NSString* line;
	NSString* by;
	Boolean   system;
	Boolean   visitor;
	NSString* date;
	NSString* _id;
}
@property (nonatomic, retain) NSString* line;
@property (nonatomic, retain) NSString* by;
@property (nonatomic, readwrite) Boolean system;
@property (nonatomic, readwrite) Boolean visitor;
@property (nonatomic, retain) NSString* date;
@property (nonatomic, retain) NSString* _id;	
@end

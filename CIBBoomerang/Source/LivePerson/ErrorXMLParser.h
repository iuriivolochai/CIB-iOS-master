//
//  ErrorXMLParser.h
//  chatApp4
//
//  Created by asaf on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ErrorXMLParser : NSObject<NSXMLParserDelegate> {
	NSString* message;
	NSString* time;
	NSInteger errCode;
	NSString* reason;
	NSMutableString* currentElementValue;
}
@property (nonatomic, retain) NSString* message;
@property (nonatomic, retain) NSString* time;
@property (nonatomic, readonly) NSInteger errCode;
@property (nonatomic, retain) NSString* reason;
@end

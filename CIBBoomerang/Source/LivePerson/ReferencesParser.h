//
//  ReferencesParser.h
//  chatApp4
//
//  Created by asaf on 6/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ReferencesParser : NSObject<NSXMLParserDelegate> {
	NSString* chatAvailability;
	NSString* chatRequest;
}
@property (nonatomic, readonly) NSString* chatAvailability;
@property (nonatomic, readonly) NSString* chatRequest;
@end

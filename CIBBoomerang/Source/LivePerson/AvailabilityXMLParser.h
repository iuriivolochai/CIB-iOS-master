//
//  AvailabilityXMLParser.h
//  chatApp4
//
//  Created by asaf on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AvailabilityXMLParser : NSObject<NSXMLParserDelegate> {
	Boolean avail;
	NSMutableString* currentElementValue;
}
@property (nonatomic) Boolean avail;
@end

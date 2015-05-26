//
//  CBLogentriesFormatter.h
//  CIBBoomerang
//
//  Created by Alexander on 4/30/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface CBLogentriesFormatter : NSObject <DDLogFormatter>
{
    int atomicLoggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}

@end

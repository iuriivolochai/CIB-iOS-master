//
//  CBLogentriesLog.m
//  CIBBoomerang
//
//  Created by Alexander on 4/30/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

#import "CBLogentriesLog.h"
#import "lelib.h"

@interface CBLogentriesLog ()

@end

@implementation CBLogentriesLog

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *log = [formatter formatLogMessage:logMessage];
    [self.leLog log:log];
}


@end

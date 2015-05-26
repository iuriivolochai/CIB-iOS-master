//
//  CBLogentriesFormatter.m
//  CIBBoomerang
//
//  Created by Alexander on 4/30/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

#import "CBLogentriesFormatter.h"
#import <libkern/OSAtomic.h>

@implementation CBLogentriesFormatter

- (NSString *)stringFromDate:(NSDate *)date
{
    int32_t loggerCount = OSAtomicAdd32(0, &atomicLoggerCount);
    
    if (loggerCount <= 1)
    {
        // Single-threaded mode.
        
        if (threadUnsafeDateFormatter == nil)
        {
            threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
            [threadUnsafeDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [threadUnsafeDateFormatter setDateFormat:@"yyyy.MM.dd"];
        }
        
        return [threadUnsafeDateFormatter stringFromDate:date];
    }
    else
    {
        // Multi-threaded mode.
        // NSDateFormatter is NOT thread-safe.
        
        NSString *key = @"MyCustomFormatter_NSDateFormatter";
        
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
        NSDateFormatter *dateFormatter = [threadDictionary objectForKey:key];
        
        if (dateFormatter == nil)
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [dateFormatter setDateFormat:@"yyyy.MM.dd"];
            
            [threadDictionary setObject:dateFormatter forKey:key];
        }
        
        return [dateFormatter stringFromDate:date];
    }
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : logLevel = @"ERROR"; break;
        case LOG_FLAG_WARN  : logLevel = @"WARNING"; break;
        case LOG_FLAG_INFO  : logLevel = @"INFO"; break;
        case LOG_FLAG_DEBUG : logLevel = @"DEBUG"; break;
        default             : logLevel = @"VERBOSE"; break;
    }
    
    NSString *dateAndTime = [self stringFromDate:(logMessage->timestamp)];
    NSString *logMsg = logMessage->logMsg;
    
    NSString *file = [[NSString stringWithUTF8String:logMessage->file] lastPathComponent];
    NSString *function = [NSString stringWithUTF8String:logMessage->function];
    
    return [NSString stringWithFormat:@"%@ %@ | %@:%d %@ | %@\n", logLevel, dateAndTime, file, logMessage->lineNumber, function, logMsg];
}

- (void)didAddToLogger:(id <DDLogger>)logger
{
    OSAtomicIncrement32(&atomicLoggerCount);
}
- (void)willRemoveFromLogger:(id <DDLogger>)logger
{
    OSAtomicDecrement32(&atomicLoggerCount);
}

@end

//
//  NSDate+CLRTicks.m
//  CIBBoomerang
//
//  Created by Roma on 6/7/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "NSDate+CLRTicks.h"

@implementation NSDate (CLRTicks)

+ (NSDate *)ticksToDate:(NSString *)ticks
{
    long long tickFactor = 10000000;
    long long ticksDoubleValue = [ticks longLongValue];
    long long seconds = ((ticksDoubleValue - 621355968000000000)/ tickFactor);
    NSDate *returnDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    return returnDate;
}

+ (NSString *)dateToTicks:(NSDate *)date
{
    long long tickFactor = 10000000;
    long long timeSince1970 = [date timeIntervalSince1970];
    long long llValue = (long long)floor(timeSince1970 * tickFactor) + 621355968000000000LL;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber *nsNumber = [NSNumber numberWithLongLong:llValue];
    return [numberFormatter stringFromNumber:nsNumber];
}

- (NSDate *)midnightUTC
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                   fromDate:self];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    NSDate *midnightUTC = [calendar dateFromComponents:dateComponents];
    
    return midnightUTC;
}

@end

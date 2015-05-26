//
//  CBDateConvertionUtils.m
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 5/7/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBDateConvertionUtils.h"

#define CARNET_DATE_FORMAT              @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#define CARNET_UPDATE_FORMAT            @"MM-dd-yyyy"
#define CARNET_DAY_AND_MONTH_FORMAT     @"MMM dd"
#define CARNET_YEAR_FORMAT              @"yyyy"
#define CHAT_DATE_FORMAT                @"'dd' 'MMMM' 'yyyy', 'HH':'mm'"

@implementation CBDateConvertionUtils

static NSDateFormatter *formatter;

+ (void)initialize
{
    formatter = [[NSDateFormatter alloc] init];
}

+ (NSTimeInterval)carnetTimeIntervalFromString:(NSString *)dateString
{
	[formatter setDateFormat:CARNET_DATE_FORMAT];
	return [[formatter dateFromString:dateString] timeIntervalSinceReferenceDate];
}

+ (NSString *)chatDateStringFromDate:(NSDate *)chatDate
{
	[formatter setDateFormat:CHAT_DATE_FORMAT];
	return [formatter stringFromDate:chatDate];
}

+ (NSString *)dateStringFromCarnetTimeInterval:(NSTimeInterval)timeInterval
{
	[formatter setDateFormat:CARNET_DATE_FORMAT];
	return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval]];
}

+ (NSString *)expiringDateFromTimeInterval:(NSTimeInterval)interval
{
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:interval]];
}

+ (NSString *)expiringDayAndMonthFromTimeInterval:(NSTimeInterval)interval
{
    [formatter setDateFormat:CARNET_DAY_AND_MONTH_FORMAT];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:interval]];
}

+ (NSString *)expiringYearTimeInterval:(NSTimeInterval)interval
{
    [formatter setDateFormat:CARNET_YEAR_FORMAT];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:interval]];
}

+ (NSString *)solicitinViewDisplayDate:(NSDate *)date
{
    [formatter setDateStyle:NSDateFormatterLongStyle];
    return [formatter stringFromDate:date];
}

+ (NSString *)serverDepartureStringFromDate:(NSDate *)date
{
    [formatter setDateFormat:CARNET_UPDATE_FORMAT];
    NSString *retString = [formatter stringFromDate:date];
    return retString;
}

+ (NSDate *)addDays:(int)daysCount toDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:daysCount];
    
    NSDate *newDate = [[NSCalendar currentCalendar]
                       dateByAddingComponents:dateComponents
                       toDate:date
                       options:0];
    return newDate;
}

+ (NSTimeInterval)addMinutes:(int)minutes toDate:(NSDate *)date
{
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMinute:minutes];
    
    NSDate *newDate = [[NSCalendar currentCalendar]
                       dateByAddingComponents:dateComponents
                       toDate:date
                       options:0];
	
    return [newDate timeIntervalSince1970];
}

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (NSInteger)daysBetweenTimeInterval:(NSTimeInterval)fromTimeInterval andTimeInteraval:(NSTimeInterval)timeInterval
{
    NSDate *fromDateTime = [NSDate dateWithTimeIntervalSince1970:fromTimeInterval];
    NSDate *toDateTime = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (BOOL)isDayPassedFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    return ([CBDateConvertionUtils daysBetweenDate:fromDate andDate:toDate] > 1);
}

+ (BOOL)isDayPassedFromTimeInterval:(NSTimeInterval)fromTimeInterval toTimeInterval:(NSTimeInterval)toTimeInterval
{
    return ([CBDateConvertionUtils daysBetweenTimeInterval:fromTimeInterval andTimeInteraval:toTimeInterval] > 1);
}


@end

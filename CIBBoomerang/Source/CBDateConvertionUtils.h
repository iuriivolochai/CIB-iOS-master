//
//  CBDateConvertionUtils.h
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 5/7/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBDateConvertionUtils : NSObject

+ (BOOL)isDayPassedFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (BOOL)isDayPassedFromTimeInterval:(NSTimeInterval)fromTimeInterval toTimeInterval:(NSTimeInterval)toTimeInterval;
+ (NSTimeInterval)addMinutes:(int)minutes toDate:(NSDate *)date;
+ (NSTimeInterval)carnetTimeIntervalFromString:(NSString *)dateString;
+ (NSString *)chatDateStringFromDate:(NSDate *)chatDate;
+ (NSString *)serverDepartureStringFromDate:(NSDate *)date;
+ (NSString *)dateStringFromCarnetTimeInterval:(NSTimeInterval)timeInterval;
+ (NSString *)expiringDateFromTimeInterval:(NSTimeInterval)interval;
+ (NSString *)expiringDayAndMonthFromTimeInterval:(NSTimeInterval)interval;
+ (NSString *)expiringYearTimeInterval:(NSTimeInterval)interval;
+ (NSString *)solicitinViewDisplayDate:(NSDate *)date;
+ (NSDate *)addDays:(NSInteger)daysCount toDate:(NSDate *)date;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (NSInteger)daysBetweenTimeInterval:(NSTimeInterval)fromTimeInterval andTimeInteraval:(NSTimeInterval)timeInterval;

@end

//
//  NSDate+CLRTicks.h
//  CIBBoomerang
//
//  Created by Roma on 6/7/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CLRTicks)

+ (NSString *)dateToTicks:(NSDate *)date;
+ (NSDate *)ticksToDate:(NSString *)ticks;
- (NSDate *)midnightUTC;

@end

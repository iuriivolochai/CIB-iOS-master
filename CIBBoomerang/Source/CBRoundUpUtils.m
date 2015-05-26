//
//  CBRoundUpUtils.m
//  CIBBoomerang
//
//  Created by Roma on 6/6/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBRoundUpUtils.h"
#import <math.h>

#define MILLION     1000000.f
#define THOUSAND    1000.f
#define TEN         10.f

static NSNumberFormatter *formatter;
static NSNumberFormatter *dotFormatter;

@implementation CBRoundUpUtils

+ (void)initialize
{
    formatter = [[NSNumberFormatter alloc] init];
    [formatter setMinimumFractionDigits:0];
    [formatter setMaximumFractionDigits:1];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setDecimalSeparator:@"."];
    [formatter setAlwaysShowsDecimalSeparator:NO];
    
    dotFormatter = [[NSNumberFormatter alloc] init];
    [dotFormatter setMinimumFractionDigits:2];
    [dotFormatter setMaximumFractionDigits:2];
    [dotFormatter setGroupingSeparator:@","];
    [dotFormatter setDecimalSeparator:@"."];
    [dotFormatter setGroupingSize:3];
    [dotFormatter setUsesGroupingSeparator:YES];
}

+ (NSString *)roundedUpFormFloat:(float)value
{
    if (value > MILLION) {
        return [CBRoundUpUtils resultingStringForValue:value mod:MILLION multiplier:@"M"];
    }
    else if (value > THOUSAND) {
        return [CBRoundUpUtils resultingStringForValue:value mod:THOUSAND multiplier:@"K"];
    }
    else {
        return [NSString stringWithFormat:@"%d", (int)roundf(value)];
    }
}

+ (NSString *)resultingStringForValue:(float)value mod:(float)mod multiplier:(NSString *)multiplier
{
    NSString *result = [formatter stringFromNumber:[NSNumber numberWithFloat:value/mod]];
    return [NSString stringWithFormat:@"%@%@", result, multiplier];
}

+ (NSString *)dottedNumberFromNumber:(NSNumber *)number
{
    return [dotFormatter stringFromNumber:number];
}

@end

//
//  CBLocation.m
//  CIBBoomerang
//
//  Created by Roma on 8/5/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBLocation.h"

NSString *const CBLocationUndefinedCountry  = @"UNDEFINED_ISO_CODE";

@implementation CBLocation

+ (instancetype)locationWithCLLocation:(CLLocation *)aLocation
                        countryISOCode:(NSString *)countryCode
{
    return [[self alloc] initWithCLLocation:aLocation ISOCode:countryCode];
}

- (id)initWithCLLocation:(CLLocation *)aLocation ISOCode:(NSString *)aISOCode
{
    self = [super init];
    if (self) {
        self.clLocation   = aLocation;
        self.countryISO = (aISOCode.length) ? aISOCode : CBLocationUndefinedCountry;
    }
    return self;
}

- (BOOL)ISOCodeSpecified
{
    return (self.countryISO.length == kCountryISOCodeMAXLength);
}

@end

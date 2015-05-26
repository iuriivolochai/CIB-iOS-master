//
//  DMCountry.m
//  CIBBoomerang
//
//  Created by Roma on 9/3/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMCountry.h"
#import "DMCheckpoint.h"
#import "DMCountryAlert.h"
#import "DMWaypoint.h"

@implementation DMCountry

@dynamic code;
@dynamic identifier;
@dynamic name;
@dynamic supportsCarnet;
@dynamic checkpoints;
@dynamic waypoints;
@dynamic alert;

#pragma mark - CBLocation

- (CLLocation *)clLocation
{
    return [[CLLocation alloc] initWithLatitude:0 longitude:0];
}

- (NSString *)countryISO
{
    return self.identifier;
}

- (BOOL)ISOCodeSpecified
{
    return (self.countryISO.length == kCountryISOCodeMAXLength);
}

@end

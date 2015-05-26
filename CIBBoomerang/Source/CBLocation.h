//
//  CBLocation.h
//  CIBBoomerang
//
//  Created by Roma on 8/5/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#define kCountryISOCodeMAXLength    2

@class CLLocation;

@protocol CBLocation

@property (nonatomic, readonly) CLLocation *clLocation;
@property (nonatomic, readonly) NSString *countryISO;

- (BOOL)ISOCodeSpecified;

@end


@interface CBLocation : NSObject <CBLocation>

@property (strong, nonatomic) CLLocation    *clLocation;
@property (strong, nonatomic) NSString      *countryISO;

+ (instancetype)locationWithCLLocation:(CLLocation *)aLocation
                        countryISOCode:(NSString *)countryCode;

@end

//
//  DMCountry+Auxilliary.h
//  CIBBoomerang
//
//  Created by Roma on 4/25/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMCountry.h"

@interface DMCountry (Auxilliary)

+ (DMCountry *)countryByCode:(int16_t)code;
+ (DMCountry *)countryByIdentifier:(NSString *)identifier;
+ (DMCountry *)countryByIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext*)context;
+ (NSArray *)countries;
+ (NSInteger)count;
- (BOOL)isUSA;
- (BOOL)isEU;

- (BOOL)showCountryAlert;
- (void)setAlertShown:(BOOL)shown;
- (void)setAirportsAlertShown:(BOOL)shown;

- (NSArray *)aiportsAlerts;
- (void)refreshCountryState;

@end

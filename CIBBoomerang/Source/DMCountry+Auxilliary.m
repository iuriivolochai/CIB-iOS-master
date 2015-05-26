//
//  DMCountry+Auxilliary.m
//  CIBBoomerang
//
//  Created by Roma on 4/25/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMCountry+Auxilliary.h"
#import "DMCountryAlert+Auxilliary.h"
#import "DMManager.h"


NSString *const keyDMCountryAlertText = @"Text";

static NSSet *euCountriesList;

@implementation DMCountry (Auxilliary)

+ (DMCountry *)countryByCode:(int16_t)code
{
    DMCountry *managedObject = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %d", code];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [[DMManager managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    if ([results count]) {
        managedObject = [results lastObject];
    }
    
    return managedObject;
    
}

+ (DMCountry *)countryByIdentifier:(NSString *)identifier
{
	return [self countryByIdentifier:identifier inContext:[DMManager managedObjectContext]];
}

+ (DMCountry *)countryByIdentifier:(NSString *)identifier inContext:(NSManagedObjectContext*)context
{
    DMCountry *managedObject = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    NSPredicate *predicate = nil;
    predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    if ([results count]) {
        managedObject = [results lastObject];
    }
    
    return managedObject;
}

+ (NSInteger)count
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    [request setIncludesSubentities:NO];
    return [[DMManager managedObjectContext] countForFetchRequest:request error:nil];
    
}

+ (NSArray *)countries
{
    NSManagedObjectContext *context = [DMManager managedObjectContext];
    NSFetchRequest *fetchRequest    = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return error ? nil : fetchedObjects;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %p %@ %@",[self class], self, self.name, self.identifier];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@ %p %@ %@>",[self class], self, self.name, self.identifier];
}

- (BOOL)isUSA
{
    return [self.identifier isEqualToString:@"US"];
}

- (BOOL)isEU
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        euCountriesList = [NSSet setWithObjects:@"BE", @"BG", @"CZ", @"DK", @"DE", @"EE", @"IE", @"EL", @"ES", @"FR",
                           @"HR", @"IT", @"CY", @"LV", @"LT", @"LU", @"HU", @"MT", @"NL", @"AT", @"PL", @"PT", @"RO",
                           @"SI", @"SK", @"FI", @"SE", @"UK", nil];
    });
    return [euCountriesList containsObject:self.countryISO];
}

- (BOOL)showCountryAlert
{
    return (self.alert && !self.alert.shown);
}

- (void)setAlertShown:(BOOL)shown
{
    self.alert.shown = shown;
}

- (NSArray *)aiportsAlerts
{
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:self.checkpoints.count];
    for (DMCheckpoint *checkpoint in self.checkpoints) {
        if (checkpoint.alert && [checkpoint hasAlertToShow]) {
            [retArray addObject:checkpoint.alert];
        }
    }
    return retArray;
}

- (void)setAirportsAlertShown:(BOOL)shown
{
    for (DMCheckpoint *checkpoint in self.checkpoints) {
        [checkpoint setAlertShown:YES];
    }
}

- (void)refreshCountryState
{
    if (self.alert) {
        [self setAlertShown:NO];
    }
    else {
        [DMManager loadAlertForCountryWithISOCode:self.identifier
                                completionHandler:^(NSDictionary *alertsDic, BOOL isErrorOccured) {
                                    if (!isErrorOccured) {
                                        //NSString *text = alertsDic[keyDMCountryAlertText];
                                        NSString *text = nil;
                                        NSString *key = keyDMCountryAlertText;
                                        for (NSString *dKey in [alertsDic allKeys]) {
                                            if ([key caseInsensitiveCompare:dKey] == NSOrderedSame) {
                                                text = [alertsDic objectForKey:dKey];
                                            }
                                        }
                                        
                                        if (text && [text isKindOfClass:[NSString class]]) {
                                            [self addCountryAlertWithText:text];
                                        }
                                    }
                                }];
    }
}

- (void)addCountryAlertWithText:(NSString *)aText
{
    DMCountryAlert *alert   = [DMCountryAlert newCountryAlert];
    alert.text              = aText;
    alert.country           = self;
    
//    BOOL textSpecifed       = [aText isKindOfClass:[NSString class]];
//    alert.text              = (textSpecifed) ? aText : NSLocalizedString(@"No specified information for this country", nil);
    
    [DMManager saveContext];
}
@end

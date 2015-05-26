//
//  DMWaypoint+Auxilliary.m
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 4/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMWaypoint+Auxilliary.h"
#import "DMCountry+Auxilliary.h"
#import "CBDateConvertionUtils.h"

NSString *const keyDMWaypointParsingCountryId   = @"CountryId";
NSString *const keyDMWaypointParsingDate        = @"Date";
NSString *const keyDMWaypointParsingKind        = @"Kind";
NSString *const keyDMWaypointParsingStatus      = @"Processed";

NSString *const keyDMWaypointArrivalDate    = @"dateArrival";
NSString *const keyDMWaypointDepartureDate  = @"dateDeparture";
NSString *const keyDMWaypointObjectID       = @"objectID";

NSString * const keyDMCarnetCurrentWaypoint = @"activeForCarnet";

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation DMWaypoint (Auxilliary)

#pragma mark - Public

+ (DMWaypoint *)obtainWaypointObjectWithCountryID:(NSString *)countryID
                                      arrivalDate:(NSDate *)arrivalDate
                                     depatureDate:(NSDate *)departureDate
                                             kind:(DMWaypointKind)kind
                                           status:(DMWaypointStatus)status
{
    DMWaypoint *waypoint = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
														 inManagedObjectContext:[DMManager managedObjectContext]];
    
	DMCountry *country = [DMCountry countryByIdentifier:countryID];
    
	if (!country) {
		[[DMManager managedObjectContext] deleteObject:waypoint];
		return nil;
	}

//    NSLog(@"____________________%@", arrivalDate);

    waypoint.dateArrival    = [arrivalDate timeIntervalSinceReferenceDate];

//    NSDate *Dd = [NSDate dateWithTimeIntervalSinceReferenceDate:waypoint.dateArrival];
    
//    NSLog(@"____________________%@", Dd);
    
    waypoint.country        = country;
	waypoint.kind           = kind;
    waypoint.status         = status;

    if (!departureDate)
        waypoint.dateDeparture  = [departureDate timeIntervalSinceReferenceDate];

    return waypoint;
    
}

+ (DMWaypoint *)obtainWaypointWithData:(NSDictionary *)waypointData
{
    NSString *coutryId      = waypointData [keyDMWaypointParsingCountryId];
	NSDate *date            = [NSDate dateWithTimeIntervalSinceReferenceDate:[CBDateConvertionUtils carnetTimeIntervalFromString:waypointData[keyDMWaypointParsingDate]]];
    NSUInteger kindInt      = [waypointData[keyDMWaypointParsingKind] integerValue];
    DMWaypointKind kind;
    BOOL containsError = NO;
    if (kindInt % 2 == 0) {
        kind = kindInt;
    }
    else {
        kind = kindInt - 1;
        containsError = YES;
    }
	DMWaypointStatus status = [waypointData [keyDMWaypointParsingStatus] integerValue];

    DMWaypoint *object = [self obtainWaypointObjectWithCountryID:coutryId
                                                     arrivalDate:date
                                                    depatureDate:nil
                                                            kind:kind
                                                          status:status];
    object.containsError = containsError;
    return object;
}

+ (DMWaypoint *)obtainDefaultWaypoint
{
    /*{
     CountryId = US;
     Date = "1970-01-01T00:00:00Z";
     Guid = "55eec5f2-fd75-4112-b94b-a1a6f8bfcf00";
     Kind = 2;
     Processed = 1;
     },*/
    
    return [self obtainWaypointObjectWithCountryID:@"US"
                                       arrivalDate:[NSDate dateWithTimeIntervalSince1970:0]
                                      depatureDate:nil
                                              kind:DMWaypointKindStartpoint
                                            status:1];
}

- (BOOL)containsErrors
{
    NSArray *alertsArray = [self getAlertsArray];
    NSExpression *leftExpression    = [NSExpression expressionForKeyPath:DMLocationAlertPriority];
    NSExpression *rightExpression   = [NSExpression expressionForConstantValue:@1];
    NSPredicate *predicate          = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                         rightExpression:rightExpression
                                                                                modifier:NSDirectPredicateModifier
                                                                                    type:NSEqualToPredicateOperatorType
                                                                                 options:NSNormalizedPredicateOption];
    
    NSArray *filteredArray = [alertsArray filteredArrayUsingPredicate:predicate];
    BOOL retValue = filteredArray.count;
    
    return retValue;
}

- (BOOL)containsAlerts
{
    NSArray *alertsArray = [self getAlertsArray];
    BOOL retValue        = alertsArray.count;
    return retValue;
}

- (BOOL)containsOnlyPopovers
{
    return ([self popoversAlerts].count);
}

- (NSArray *)getAlertsArray
{
    NSExpression *leftExpression    = [NSExpression expressionForKeyPath:DMLocationAlertShownKey];
    NSExpression *rightExpression   = [NSExpression expressionForConstantValue:@NO];
    NSPredicate *predicate          = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                         rightExpression:rightExpression
                                                                                modifier:NSDirectPredicateModifier
                                                                                    type:NSEqualToPredicateOperatorType
                                                                                 options:NSNormalizedPredicateOption];
    
    NSSet *filteredSet = [self.alerts filteredSetUsingPredicate:predicate];
    [filteredSet makeObjectsPerformSelector:@selector(attachAlertPreferences)];
    
    NSExpression *occuranceLeftExpression   = [NSExpression expressionForKeyPath:DMLocationAlertOccurence];
    NSExpression *occuranceRightExpression  = [NSExpression expressionForConstantValue:@0];
    NSPredicate *occurancePredicate         = [NSComparisonPredicate predicateWithLeftExpression:occuranceLeftExpression
                                                                                 rightExpression:occuranceRightExpression
                                                                                        modifier:NSDirectPredicateModifier
                                                                                            type:NSEqualToPredicateOperatorType
                                                                                         options:NSNormalizedPredicateOption];
    NSArray *filteredArray = [[filteredSet filteredSetUsingPredicate:occurancePredicate] allObjects];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"alertPriority" ascending:NO];
    NSArray *retArray = [filteredArray sortedArrayUsingDescriptors:@[descriptor]];
    return retArray;
}

- (NSArray *)popoversAlerts
{
    NSExpression *leftExpression    = [NSExpression expressionForKeyPath:DMLocationAlertShownKey];
    NSExpression *rightExpression   = [NSExpression expressionForConstantValue:@NO];
    NSPredicate *predicate          = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                         rightExpression:rightExpression
                                                                                modifier:NSDirectPredicateModifier
                                                                                    type:NSEqualToPredicateOperatorType
                                                                                 options:NSNormalizedPredicateOption];
    
    NSSet *filteredSet = [self.alerts filteredSetUsingPredicate:predicate];
    [filteredSet makeObjectsPerformSelector:@selector(attachAlertPreferences)];
    
    NSExpression *occuranceLeftExpression   = [NSExpression expressionForKeyPath:DMLocationAlertOccurence];
    NSExpression *occuranceRightExpression  = [NSExpression expressionForConstantValue:@1];
    NSPredicate *occurancePredicate         = [NSComparisonPredicate predicateWithLeftExpression:occuranceLeftExpression
                                                                                 rightExpression:occuranceRightExpression
                                                                                        modifier:NSDirectPredicateModifier
                                                                                            type:NSEqualToPredicateOperatorType
                                                                                         options:NSNormalizedPredicateOption];
    NSArray *retArray = [[filteredSet filteredSetUsingPredicate:occurancePredicate] allObjects];
    return retArray;
}

- (NSDictionary *)parametrsForPatch
{
    NSString *date = [CBDateConvertionUtils serverDepartureStringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.dateArrival]];
    
    return  @{   keyDMWaypointParsingCountryId   :   self.country.identifier,
                 keyDMWaypointParsingDate        :   date,
                 keyDMWaypointParsingKind        :   @(self.kind),
                 keyDMWaypointParsingStatus      :   @(self.status)
            };
}

- (void)addLocationAlertWithType:(CBAlertType)aType
{
    DMLocationAlert *alert = [self alertWithType:aType];
    if (alert)
        return;
    
    alert = [DMLocationAlert obtainLocationAlertWithType:aType];
    alert.waypoint = self;
}

- (void)addLocationAlertWithType:(CBAlertType)aType showDate:(NSTimeInterval)aTimeInterval
{
    DMLocationAlert *alert = [self alertWithType:aType];
    if (alert) {
        if ([CBDateConvertionUtils isDayPassedFromTimeInterval:alert.showingDate toTimeInterval:aTimeInterval]) {
            alert.shown = NO;
        }
        else {
            return;
        }
    } else {
        alert = [DMLocationAlert obtainLocationAlertWithType:aType];
    }
    
    alert.showingDate   = aTimeInterval;
    alert.waypoint      = self;
}

- (DMLocationAlert *)alertWithType:(CBAlertType)aType
{
    __block DMLocationAlert *locAlert;
    [self.alerts enumerateObjectsUsingBlock:^(DMLocationAlert *anAlert, BOOL *stop) {
        if (anAlert.type == aType) {
            locAlert = anAlert;
            *stop = YES;
        }
    }];
    return locAlert;
}

- (void)replaceAlertWithType:(CBAlertType)aType withAlert:(DMLocationAlert *)anAlert
{
    DMLocationAlert *alert = [self alertWithType:aType];
    if (alert)
        [self removeAlertsObject:alert];
    
    anAlert.waypoint = self;
    [self addAlertsObject:anAlert];
}

- (BOOL)isActiveAtDate:(NSDate *)aDate
{
    NSDate *arrivalDate     = [NSDate dateWithTimeIntervalSinceReferenceDate:self.dateArrival];
    NSDate *departureDate   = [NSDate dateWithTimeIntervalSinceReferenceDate:self.dateDeparture];
    BOOL isArrivalEarlier   = ([arrivalDate compare:aDate] == (NSOrderedAscending | NSOrderedSame));
    BOOL isDepartureLater   = ([departureDate compare:aDate] == (NSOrderedDescending | NSOrderedSame));
    BOOL isActive           = (isArrivalEarlier && isDepartureLater);
    return isActive;
}

#pragma mark - PrivateisAlertWasShownDayAgo

- (BOOL)showRemoveAtUSAAlertActive:(BOOL)active
{
    return (self.status == DMWaypointKindEndpoint && [self.country isUSA] && active);
}

- (BOOL)showWelcomeValidationActive:(BOOL)active
{
    return (![self.country isUSA] && active);
}

- (BOOL)showUSADepartureValidation:(BOOL)active travelDay:(BOOL)travelDay
{
    return ([self.country isUSA] && self.status == DMWaypointKindStartpoint && active && travelDay);
}

- (BOOL)showWrongCountryAlert
{
    return self.containsError;
}

+ (NSArray *)activeWaypointsWithDepartureDate:(NSDate *)aDepartureDate
{
    NSFetchRequest  *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    NSExpression    *leftExpr  =    [NSExpression expressionForKeyPath:keyDMCarnetCurrentWaypoint];
    NSExpression    *rightExpr =    [NSExpression expressionForConstantValue:nil];
    NSPredicate     *predicate =    [NSComparisonPredicate  predicateWithLeftExpression:leftExpr
                                                                        rightExpression:rightExpr
                                                                               modifier:NSDirectPredicateModifier
                                                                                   type:NSNotEqualToPredicateOperatorType
                                                                                options:NSNormalizedPredicateOption];
    
    [fetchRequest   setPredicate:predicate];
    
    NSError *error;
    NSArray *retarray = [[DMManager managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"%@", error.localizedDescription);
        return nil;
    }
    
    return retarray;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"Country - %@\n status - %d\n, kind = %d, \n ", self.country.identifier, self.status, self.kind];
}

@end

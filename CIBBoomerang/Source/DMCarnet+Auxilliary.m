//
//  DMCarnet+Auxilliary.m
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 4/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMCarnet+Auxilliary.h"
#import "CBDateConvertionUtils.h"
#import "DMCheckpoint.h"
#import "DMCheckpointAlert.h"
#import "DMCountry+Auxilliary.h"
#import "DMCountryAlert+Auxilliary.h"
#import "DMWaypoint+Auxilliary.h"
#import "NSDate+CLRTicks.h"
#import "DMSimpleAlert+Auxilliary.h"
#import "CBServerLoggingUtils.h"
#import "DMManager.h"

NSString * const keyDMCarnetAccountNumber   = @"ReferenceNo";
NSString * const keyDMCarnetDateExpired     = @"ExpirationDate";
NSString * const keyDMCarnetDateIssued      = @"IssuedDate";
NSString * const keyDMCarnetIdentifier      = @"Id";
NSString * const keyDMCarnetIssuedBy        = @"Name";
NSString * const keyDMCarnetGUID            = @"Guid";
NSString * const keyDMCarnetItems           = @"Items";
NSString * const keyDMCarnetTimestamp       = @"Timestamp";
NSString * const keyDMCarnetTravelPlan      = @"TravelPlans";
NSString * const keyDMCarnetVerified        = @"keyVerifeid";
NSString * const keyDMCarnetFoilsBlue       = @"Blue";
NSString * const keyDMCarnetFoilsWhite      = @"White";
NSString * const keyDMCarnetFoilsYellow     = @"Yellow";
NSString * const keyDMCarnetIsActive        = @"flagActive";
NSString * const keyDMCarnetDeviceId        = @"TrackedByDeviceId";

static NSString *const keyDMCarnetDateArrival   = @"dateArrival";
static NSString *const keyDMCarnetDateDeparture = @"dateDeparture";

static NSInteger    kExpiringStatusTriggerInDays    = 30;
static NSInteger    kLowFoilsTemporaryDifference    = 2;
static float        kLowFoilsStatusTrigger          = 1.3f;

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation DMCarnet (Auxilliary)

#pragma mark - 
#pragma mark    Public Methods

+ (NSDate *)nextTravelDateAfterDate:(NSDate *)aFiredDate
{
    NSArray *allCarnets     = [self obtainAllCarnets];
    NSDate *minDate         = [aFiredDate dateByAddingTimeInterval:NSTimeIntervalSince1970];
    for (DMCarnet *carnet in allCarnets) {
        NSDate *date = [carnet nextCarnetTravelDateAfterDate:aFiredDate];
        if ([date compare:minDate] == NSOrderedAscending)
            minDate = date;
    }
    return minDate;
}

- (NSDate *)nextCarnetTravelDateAfterDate:(NSDate *)aFireDate
{
    NSTimeInterval fireTI = [aFireDate timeIntervalSince1970];
    __block NSTimeInterval nextTI = NSTimeIntervalSince1970;
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *aWaypoint, NSUInteger idx, BOOL *stop) {
        if (aWaypoint.dateArrival > fireTI) {
            nextTI = aWaypoint.dateArrival;
            *stop = YES;
        }
    }];
    
    return [NSDate dateWithTimeIntervalSinceReferenceDate:fireTI];
}

- (void)setActiveCarnetsWaypoint:(DMWaypoint *)aWaypoint
{
    aWaypoint.status    = DMWaypointStatusPassed;
    self.activeWaypoint = aWaypoint;
    
    if (aWaypoint.country) {
        [DMManager logServerAction:DMLoggedActionTypeCountryChanged
                      withComments:[NSString stringWithFormat:@"%@ is become active for Carnet with ID - %@", aWaypoint.country.name, self.identifier]
                         forCarnet:self];
        [self.managedObjectContext save:nil];
    }
}

- (void)setCarnetActive:(BOOL)isActive
{
    self.flagActive = isActive;
    [self refreshCarnetStatus];
}

- (void)setCarnetVerified:(BOOL)isVerified
{
    self.flagVerified = isVerified;
    [self refreshCarnetStatus];
    
    DMSimpleAlert *anAlert = [DMSimpleAlert obtainNewSimpleAlertWithType:CBSimpleAlertType_Popup_WillYouBeTravellingSoon];
    anAlert.carnet = self;
}

- (void)refreshCarnetStatus
{
    DMCarnetStatus status = DMCarnetStatusOpen;
    if ([self isNeedToVerifyCarnet])
        status = DMCarnetStatusVerifyWarning;
    else if ([self isCarnetExpirationSituationOccured])
        status = DMCarnetStatusExpireError;
    else if ([self isLowFoilsSituationOccured])
        status = DMCarnetStatusLowFoilsError;
    else if ([self isLocationErrorSituationOccured])
        status = DMCarnetStatusCountryError;
    else if ([self isCarnetExpirationSitutationWillOccure])
        status = DMCarnetStatusExpireWarning;
    //Check is this crnet will in low foils situation
    //else if ([self isLowFoilsSituationWillOccure])
        //status = DMCarnetStatusLowFoilsWarning;
    else if ([self isReconstitueWarningSituation])
        status = DMCarnetStatusSplitWarning;
    else if ([self isContainsLocationRelatedAlert])
        status = DMCarnetStatusCountryWarning;
    else if ([self isCarnetSplitted])
        status = DMCarnetStatusSplit;
    else if ([self isCarnetActive])
        status = DMCarnetStatusActive;
    else
        status = DMCarnetStatusOpen;

    self.carnetStatus = status;
}

- (NSString *)alertCountryISO
{
    __block NSString *retValue;
    [[self.waypoints reversedOrderedSet] enumerateObjectsUsingBlock:^(DMWaypoint *wpObject, NSUInteger idx, BOOL *stop) {
        if ([wpObject containsAlerts]) {
            retValue = wpObject.country.identifier;
            *stop = YES;
        }
    }];
    if (!retValue.length)
        retValue = @"X";

    return retValue;
}

- (NSString *)errorCountryISO
{
    __block NSString *retValue;
    [[self.waypoints reversedOrderedSet] enumerateObjectsUsingBlock:^(DMWaypoint *wpObject, NSUInteger idx, BOOL *stop) {
        if ([wpObject containsErrors]) {
            retValue = wpObject.country.identifier;
            *stop = YES;
        }
    }];
    
    if (!retValue.length)
        retValue = @"X";
    return retValue;
}

- (DMManagerAlertHandlingAction)handleButtonWithTypeTapped:(CBAlertButtonType)aButtonType forSimpleAlertWithType:(CBAlertType)anAlertType
{
    if (anAlertType == CBAlertType_CountryAlert) {
        DMCountryAlert *alert   = self.activeWaypoint.country.alert;
        alert.shown             = YES;
        alert.showingDate       = [[[NSDate date] midnightUTC] timeIntervalSinceReferenceDate];
    }
    else
        if (anAlertType == CBAlertType_AiportAlert) {
            [self.activeWaypoint.country setAirportsAlertShown:YES];
        }
        else {
            DMSimpleAlert *alert    = [self alertWithType:anAlertType];
            alert.shown             = YES;
            alert.showingDate       = [[[NSDate date] midnightUTC] timeIntervalSinceReferenceDate];
        }
    
    DMManagerAlertHandlingAction retAction;
    
    switch (anAlertType) {
        case CBSimpleAlertType_Warning_Signed:
        case CBSimpleAlertType_Error_Expiring:
        case CBSimpleAlertType_Warning_Expiring:
        case CBSimpleAlertType_Warning_LowFoils:
            retAction = DMManagerAlertHandlingAction_Dismiss;
            break;
        case CBSimpleAlertType_Error_LowFoils: {
            retAction = DMManagerAlertHandlingAction_Dismiss;
            [DMManager logServerAction:DMLoggedActionTypeLowFoils
                          withComments:[NSString stringWithFormat:@"Carnet with ID - %@ is in Low Foils situation", self.identifier]
                             forCarnet:self];
        }
            break;
        case CBSimpleAlertType_Warning_Verify: {
            if (aButtonType == CBAlertButtonType_Reject) {
                [DMManager rejectCarnet:self];
                retAction = DMManagerAlertHandlingAction_PopController;
            }
            else {
                [DMManager verifyCarnet:self];
                retAction = DMManagerAlertHandlingAction_ShowPopoverAlerts;
            }
        }
            break;
        case CBSimpleAlertType_Popup_WillYouBeTravellingSoon:
            [DMManager logServerAction:DMLoggedActionTypeTravellingSoonPrompt
                          withComments:@"Travelling soon"
                         forCarnetGUID:self.guid];
            if (aButtonType == CBAlertButtonType_YES) {
                retAction = DMManagerAlertHandlingAction_ShowTravelDetailsScreen;
                [self setCarnetActive:YES];
            }
            else
                retAction = DMManagerAlertHandlingAction_ShowReminderPicker;
            break;
        default:
                retAction = DMManagerAlertHandlingAction_Dismiss;
    }
    return retAction;
}

- (DMManagerAlertHandlingAction)handleButtonWithTypeTapped:(CBAlertButtonType)aButtonType forLocationAlertWithType:(CBAlertType)anAlertType atWaypoint:(DMWaypoint *)aWaypoint
{
    DMLocationAlert *alert  = [aWaypoint alertWithType:anAlertType];
    
    if (anAlertType != CBLocationAlertType_Scan) {
        alert.shown             = YES;
        alert.showingDate       = [[[NSDate date] midnightUTC] timeIntervalSinceReferenceDate];
    }
    
    DMManagerAlertHandlingAction retAction;
    switch (anAlertType) {
        case CBLocationAlertType_Travelling_All_Items: {
            if (aButtonType == CBAlertButtonType_TakeAll) {
                [self takeAllItemsFromWaypoint:aWaypoint];
            }
            retAction = DMManagerAlertHandlingAction_Dismiss;
        }
            break;
        case CBLocationAlertType_Validation:
        case CBLocationAlertType_Validation_US:
        case CBLocationAlertType_Stamp:
            retAction = DMManagerAlertHandlingAction_Dismiss;
            break;
        case CBLocationAlertType_Reconstitute: {
            if (aButtonType == CBAlertButtonType_Reconstitute)
                [self reconstitueAllItemsForWaypoint:aWaypoint];
            retAction = DMManagerAlertHandlingAction_Dismiss;
        }
            break;
        case CBLocationAlertType_UnknowError:
        case CBLocationAlertType_Wrong_Country: {
            aWaypoint.containsError = NO;
            retAction = DMManagerAlertHandlingAction_Scan;
        }
            break;
        case CBLocationAlertType_Scan: {
            retAction = DMManagerAlertHandlingAction_Scan;
        }
            break;
        case CBLocationAlertType_Remove_USA: {
            if (aButtonType == CBAlertButtonType_YES) {
                [DMManager removeCarnet:self];
                retAction = DMManagerAlertHandlingAction_PopController;
            }
            else {
                retAction = DMManagerAlertHandlingAction_Dismiss;
            }
        }
            break;
        case CBLocationAlertType_Accompany: {
            if (aButtonType == CBAlertButtonType_YES) {
                [self setCarnetActive:YES];
                if ([DMManager countryISO]) {
                    DMCountry *aCountry = [DMCountry countryByIdentifier:[DMManager countryISO]];
                    [self refreshStateWithCountry:aCountry];
                }
            }
            else {
                [self setCarnetActive:NO];
            }
            retAction = DMManagerAlertHandlingAction_Dismiss;
        }
            break;
        default:
            retAction = DMManagerAlertHandlingAction_Dismiss;
            break;
    }
    return retAction;
}

- (DMSimpleAlert *)alertWithType:(CBAlertType)type
{
    __block DMSimpleAlert *simpleAlert;
    [self.alerts enumerateObjectsUsingBlock:^(DMSimpleAlert *anAlert, BOOL *stop) {
        if (anAlert.type == type) {
            simpleAlert = anAlert;
            *stop = YES;
        }
    }];
    return simpleAlert;
}

- (void)addWaypointsObject:(DMWaypoint *)waypointObject
{
    NSMutableOrderedSet *waypoints = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.waypoints];
    NSAssert(waypointObject.dateArrival != 0, @"Waypoint arrival date couldn't be nil");
    
    [waypoints addObject:waypointObject];
    [waypoints sortUsingComparator:[self waypointsComparator]];
    
    int waypointsCount = waypoints.count;
    
    if (waypointsCount < 2) {
        self.waypoints = waypoints;
        return;
    }
    
    for (int i = 1; i < waypointsCount; ++i) {
        DMWaypoint *prevWaypoint    = waypoints[i - 1];
        DMWaypoint *waypoint        = waypoints[i];
        
        prevWaypoint.dateDeparture = waypoint.dateArrival;
    }
    
    self.waypoints = waypoints;
}

- (void)removeWaypointsObject:(DMWaypoint *)waypointToRemove
{
    NSMutableOrderedSet *waypoints = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.waypoints];
    
    [waypoints removeObject:waypointToRemove];
    
    [waypoints sortUsingComparator:[self waypointsComparator]];
    
    int waypointsCount = waypoints.count;
    
    if (waypointsCount < 2) {
        self.waypoints = waypoints;
        return;
    }
    
    for (int i = 1; i < waypointsCount; ++i) {
        DMWaypoint *prevWaypoint    = waypoints[i - 1];
        DMWaypoint *waypoint        = waypoints[i];
        
        prevWaypoint.dateDeparture = waypoint.dateArrival;
    }
    
    self.waypoints = waypoints;
}

- (void)resortWaypoints
{
    NSMutableOrderedSet *waypoints = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.waypoints];
    
    [waypoints sortUsingComparator:[self waypointsComparator]];
 
    int waypointsCount = waypoints.count;
    
    if (waypointsCount < 2) {
        self.waypoints = waypoints;
        return;
    }
    
    for (int i = 1; i < waypointsCount; ++i) {
        DMWaypoint *prevWaypoint    = waypoints[i - 1];
        DMWaypoint *waypoint        = waypoints[i];
        
        prevWaypoint.dateDeparture = waypoint.dateArrival;
    }
    
    self.waypoints = waypoints;
}

- (NSDictionary *)patchParametersWithSplittingData:(NSArray *)splittingItems
{
    NSMutableArray *waypointsData = [NSMutableArray arrayWithCapacity:self.waypoints.count];
    for (DMWaypoint *waypoint in self.waypoints) {
        [waypointsData addObject:[waypoint parametrsForPatch]];
    }
    
    if (splittingItems.count)
        return  @{   keyDMCarnetItems         :   splittingItems,
                     keyDMCarnetTimestamp     :   self.timestamp,
                     keyDMCarnetTravelPlan    :   waypointsData,
                     @"TrackedByDeviceId"     : [CBServerLoggingUtils deviceId]
                     };
    else
        return  @{  keyDMCarnetTimestamp     :   self.timestamp,
                    keyDMCarnetTravelPlan    :   waypointsData,
                    @"TrackedByDeviceId"     : [CBServerLoggingUtils deviceId]
                    };
}

- (NSArray *)getAlertsArray
{
    NSExpression *leftExpression    = [NSExpression expressionForKeyPath:keyDMSimpleAlertShow];
    NSExpression *rightExpression   = [NSExpression expressionForConstantValue:@NO];
    NSPredicate *predicate          = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                         rightExpression:rightExpression
                                                                                modifier:NSDirectPredicateModifier
                                                                                    type:NSEqualToPredicateOperatorType
                                                                                 options:NSNormalizedPredicateOption];
    NSSet *filteredSet = [self.alerts filteredSetUsingPredicate:predicate];
    [filteredSet makeObjectsPerformSelector:@selector(attachAlertPreferences)];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:DMSimpleAlertType ascending:NO];
    NSArray *retArray = [filteredSet sortedArrayUsingDescriptors:@[descriptor]];
    return retArray;
}

- (NSArray *)getPopoversArray
{
    NSExpression *leftExpression    = [NSExpression expressionForKeyPath:keyDMSimpleAlertShow];
    NSExpression *rightExpression   = [NSExpression expressionForConstantValue:@NO];
    NSPredicate *predicate          = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                         rightExpression:rightExpression
                                                                                modifier:NSDirectPredicateModifier
                                                                                    type:NSEqualToPredicateOperatorType
                                                                                 options:NSNormalizedPredicateOption];
    NSSet *filteredSet = [self.alerts filteredSetUsingPredicate:predicate];
    [filteredSet makeObjectsPerformSelector:@selector(attachAlertPreferences)];
    
    NSExpression *occuranceLeftExpression   = [NSExpression expressionForKeyPath:keyDMSimpleAlertOccuranceType];
    NSExpression *occuranceRightExpression  = [NSExpression expressionForConstantValue:@1];
    NSPredicate *occurancePredicate         = [NSComparisonPredicate predicateWithLeftExpression:occuranceLeftExpression
                                                                                 rightExpression:occuranceRightExpression
                                                                                        modifier:NSDirectPredicateModifier
                                                                                            type:NSEqualToPredicateOperatorType
                                                                                         options:NSNormalizedPredicateOption];
    NSArray *retArray = [[filteredSet filteredSetUsingPredicate:occurancePredicate] allObjects];
    return retArray;
}

- (NSArray *)informationAlerts
{
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:2];
    if ([self.activeWaypoint.country showCountryAlert]) {
        [retArray addObject:self.activeWaypoint.country.alert];
    }
    [retArray addObjectsFromArray:[self.activeWaypoint.country aiportsAlerts]];
    [retArray makeObjectsPerformSelector:@selector(attachAlertPreferences)];
    return retArray;
}

- (BOOL)containsLocationAlerts
{
    __block BOOL retValue = NO;
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *aWaypoint, NSUInteger idx, BOOL *stop) {
        if ([aWaypoint containsAlerts]) {
            retValue    = YES;
            *stop       = YES;
        }
    }];
    return retValue;
}

#pragma mark    Class Methods

+ (DMCarnet *)carnetByGUID:(NSString *)identifier
{
	DMCarnet *managedObject = nil;
    
    NSFetchRequest  *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    NSExpression    *leftExpr  =    [NSExpression expressionForKeyPath:[keyDMCarnetGUID lowercaseString]];
    NSExpression    *rightExpr =    [NSExpression expressionForConstantValue:identifier];
    NSPredicate     *predicate =    [NSComparisonPredicate  predicateWithLeftExpression:leftExpr
                                                                        rightExpression:rightExpr
                                                                               modifier:NSDirectPredicateModifier
                                                                                   type:NSEqualToPredicateOperatorType
                                                                                options:NSNormalizedPredicateOption];
    
    [fetchRequest   setPredicate:predicate];
    [fetchRequest   setFetchLimit:1];
    
    NSArray *results = [[DMManager managedObjectContext] executeFetchRequest:fetchRequest
                                                                       error:nil];
    
    if ([results count]) {
        managedObject = [results lastObject];
    }
    
    return managedObject;
}

+ (DMCarnet *)newCarnetWithData:(NSDictionary *)carnetData
{
	DMCarnet *carnetObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                        inManagedObjectContext:[DMManager managedObjectContext]];
    carnetObj.accountNumber     = [DMCarnet accountNumberFromAccObject:carnetData[keyDMCarnetAccountNumber]];
    carnetObj.carnetStatus      = DMCarnetStatusVerifyWarning;
    carnetObj.dateExpired       = [CBDateConvertionUtils carnetTimeIntervalFromString:carnetData[keyDMCarnetDateExpired]];
    carnetObj.dateIssued        = [CBDateConvertionUtils carnetTimeIntervalFromString:carnetData[keyDMCarnetDateIssued]];
    carnetObj.flagVerified      = (carnetData[keyDMCarnetVerified]) ? [carnetData[keyDMCarnetVerified] boolValue] : NO;
    carnetObj.guid              = carnetData[keyDMCarnetGUID];
	carnetObj.identifier        = [DMCarnet carnetIdentifierFromString:carnetData[keyDMCarnetIdentifier]];
	carnetObj.issuedBy          = carnetData[keyDMCarnetIssuedBy];
    carnetObj.timestamp         = carnetData[keyDMCarnetTimestamp];
    
    carnetObj.createOnDevice = [NSDate date];
    
    NSString *deviceId = carnetData[keyDMCarnetDeviceId];
    
    if (!deviceId || ![deviceId isKindOfClass:[NSString class]]) {
        carnetObj.trackedByDeviceId = nil;
    } else {
        carnetObj.trackedByDeviceId = deviceId;
    }
    
    /* parse foils */
    carnetObj.foilsBlue     = [carnetData[keyDMCarnetFoilsBlue] integerValue];
    carnetObj.foilsWhite    = [carnetData[keyDMCarnetFoilsWhite] integerValue];
    carnetObj.foilsYellow   = [carnetData[keyDMCarnetFoilsYellow] integerValue];
    
    /* travel plans */
	[carnetObj addTravelPlansFromArray:carnetData[keyDMCarnetTravelPlan]];
    /* items */
    [carnetObj addItemsFromArray:carnetData[keyDMCarnetItems]];
    
	return carnetObj;
}

+ (NSString *)carnetIdentifierFromString:(NSString *)idString
{
    NSString *tempString = [idString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return [tempString stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString *)accountNumberFromAccObject:(id)accObject
{
    NSString *retString;
    if ([accObject isKindOfClass:[NSString class]]) {
        retString = accObject;
    }
    else {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        retString = [formatter stringFromNumber:accObject];
    }
    return retString;
}

+ (NSArray *)obtainActiveCarnets
{
    NSFetchRequest  *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    NSExpression    *leftExpr  =    [NSExpression expressionForKeyPath:keyDMCarnetIsActive];
    NSExpression    *rightExpr =    [NSExpression expressionForConstantValue:@YES];
    NSPredicate     *predicate =    [NSComparisonPredicate  predicateWithLeftExpression:leftExpr
                                                                        rightExpression:rightExpr
                                                                               modifier:NSDirectPredicateModifier
                                                                                   type:NSEqualToPredicateOperatorType
                                                                                options:NSNormalizedPredicateOption];
    
    [fetchRequest   setPredicate:predicate];
    
    NSArray *results = [[DMManager managedObjectContext] executeFetchRequest:fetchRequest
                                                                       error:nil];
    return results;
}

+ (NSArray *)obtainAllCarnets
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    NSArray *results        = [[DMManager managedObjectContext] executeFetchRequest:request error:nil];
    return results;
}

+ (BOOL)isTravelScheduledForDate:(NSDate *)aTravelDate
{
    BOOL isScheduled = [DMWaypoint activeWaypointsWithDepartureDate:aTravelDate].count;
    return isScheduled;
}

#pragma mark -
#pragma mark    Private

- (void)addSimpleAlertWithType:(CBAlertType)aType
{
    DMSimpleAlert *alert = [DMSimpleAlert obtainNewSimpleAlertWithType:aType];
    alert.carnet = self;
}

- (void)addSimpleAlertWithType:(CBAlertType)aType showDate:(NSTimeInterval)aTimeInterval
{
    DMSimpleAlert *alert = [DMSimpleAlert obtainNewSimpleAlertWithType:aType];
    alert.showingDate = aTimeInterval;
    alert.carnet = self;
}

#pragma mark - Status Calculation

- (BOOL)isLowFoilsSituationOccured
{
    NSInteger foilsSum = self.foilsBlue + self.foilsWhite + self.foilsYellow;
    if (self.waypoints.count > 0 && foilsSum > 0) {
        CGFloat yellowFoilsCount=0;
        NSInteger blueFoilsCount=0, whiteFoilsCount=0;
        BOOL isLastTravelPlanDefaultCountry = NO, isLastTravelPlanEuCountry = NO;
        
        for (DMWaypoint *waypoint in self.waypoints) {
            isLastTravelPlanDefaultCountry = NO;
            
            if ([waypoint.country isUSA]) {
                yellowFoilsCount = yellowFoilsCount+1;
                isLastTravelPlanDefaultCountry = YES;
                isLastTravelPlanEuCountry = NO;
            }
            else if (waypoint.kind == DMWaypointKindVisit) {
                if (!isLastTravelPlanEuCountry || ![waypoint.country isEU]) {
                    whiteFoilsCount += 1;
                }
                isLastTravelPlanEuCountry = [waypoint.country isEU];
            }
            else if (waypoint.kind & DMWaypointKindTransit) {
                blueFoilsCount  += 1;
                isLastTravelPlanEuCountry = NO;
            }
        }
        NSInteger delta = isLastTravelPlanDefaultCountry ? yellowFoilsCount - 2 : yellowFoilsCount - 1;
        yellowFoilsCount = yellowFoilsCount - delta + delta * 2;
        BOOL isYellowLow = self.foilsYellow*2 - yellowFoilsCount <= 1;
        BOOL isWhiteLow = whiteFoilsCount > 0 ? self.foilsWhite - whiteFoilsCount <= 0 : self.foilsWhite - whiteFoilsCount < 0;
        BOOL isBlueLow = blueFoilsCount > 0 ? self.foilsBlue - blueFoilsCount <= 0 : self.foilsBlue - blueFoilsCount < 0;
        BOOL retValue;
        if (isYellowLow || isWhiteLow || isBlueLow) {
            retValue = YES;
            [self actualizeAlertWithType:CBSimpleAlertType_Error_LowFoils withDateInterval:[[NSDate date] timeIntervalSinceReferenceDate]];
            DDLogCVerbose(@"Carnet %@ Low Foils Situation (%d yellow, %d white, %d blue", self.identifier, self.foilsYellow, self.foilsWhite, self.foilsBlue);
        } else {
            retValue = NO;
        }
        return retValue;
    }
    return NO;
}

- (BOOL)isLowFoilsSituationOccuredOld
{
    CGFloat yellowFoilsCount    = 0;
    int blueFoilsCount      = 0;
    int whiteFoilsCount     = 0;
    BOOL isLastTravelPlanDefaultCountry, isLastTravelPlanEuCountry = NO;

    for (DMWaypoint *waypoint in self.waypoints) {
        isLastTravelPlanDefaultCountry = NO;
        
        if ([waypoint.country isUSA]) {
            yellowFoilsCount += 1;
            isLastTravelPlanDefaultCountry = YES;
            isLastTravelPlanEuCountry = NO;
        }
        else if (waypoint.status == DMWaypointStatusPassed) {
            if (!isLastTravelPlanEuCountry || ![waypoint.country isEU]) {
                whiteFoilsCount += 1;
            }
            isLastTravelPlanEuCountry = [waypoint.country isEU];
        }
        else if (waypoint.kind & DMWaypointKindTransit) {
            blueFoilsCount  += 1;
            isLastTravelPlanEuCountry = NO;
        }
    }
    int delta = isLastTravelPlanDefaultCountry ? yellowFoilsCount - 2 : yellowFoilsCount - 1;
    yellowFoilsCount = yellowFoilsCount - delta + delta * 2;
    BOOL isYellowLow = self.foilsYellow * 2 - yellowFoilsCount <= 1;
    BOOL isWhiteLow = whiteFoilsCount > 0 ? self.foilsWhite - whiteFoilsCount <= 0 : self.foilsWhite - whiteFoilsCount < 0;
    BOOL isBlueLow = blueFoilsCount > 0 ? self.foilsBlue - blueFoilsCount <= 0 : self.foilsBlue - blueFoilsCount < 0;
    BOOL retValue;
    if (isYellowLow || isWhiteLow || isBlueLow) {
        retValue = YES;
        [self actualizeAlertWithType:CBSimpleAlertType_Error_LowFoils withDateInterval:[[NSDate date] timeIntervalSinceReferenceDate]];
        DDLogCVerbose(@"Carnet %@ Low Foils Situation (%d yellow, %d white, %d blue", self.identifier, self.foilsYellow, self.foilsWhite, self.foilsBlue);
    } else {
        retValue = NO;
        //Remove alert
    }
    //BOOL retValue = !(blueFoilsCount <= self.foilsBlue && whiteFoilsCount <= self.foilsWhite);
    
    return retValue;
}

- (BOOL)isLocationErrorSituationOccured
{
    __block BOOL locError = NO;
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *waypointObject, NSUInteger idx, BOOL *stop) {
        if ([waypointObject containsErrors]) {
            locError    = YES;
            *stop       = YES;
        }
    }];
    return locError;
}

- (BOOL)isCarnetExpirationSituationOccured
{
    NSTimeInterval currentInterval  = [[NSDate date] timeIntervalSinceReferenceDate];
    NSInteger daysInterval          = [CBDateConvertionUtils daysBetweenTimeInterval:currentInterval andTimeInteraval:self.dateExpired];
    if (daysInterval <= 0) {
        DMSimpleAlert *expiredAlert = [self alertWithType:CBSimpleAlertType_Error_Expiring];
        if (!expiredAlert) {
            [self addSimpleAlertWithType:CBSimpleAlertType_Error_Expiring showDate:currentInterval];
            [DMManager logServerAction:DMLoggedActionTypeExpired
                          withComments:[NSString stringWithFormat:@"Carnet with ID - %@ is expired", self.identifier]
                             forCarnet:self];
        }
        else
            if ([CBDateConvertionUtils isDayPassedFromTimeInterval:currentInterval toTimeInterval:expiredAlert.showingDate])
                expiredAlert.shown = NO;
        
        return YES;
    }
    return NO;
}

- (BOOL)isCarnetExpirationSitutationWillOccure
{
    NSTimeInterval currentInterval  = [[NSDate date] timeIntervalSinceReferenceDate];
    NSInteger daysInterval          = [CBDateConvertionUtils daysBetweenTimeInterval:currentInterval andTimeInteraval:self.dateExpired];
    if (daysInterval <= kExpiringStatusTriggerInDays && daysInterval > 0) {
        [self actualizeAlertWithType:CBSimpleAlertType_Warning_Expiring withDateInterval:currentInterval];
        return YES;
    }
    return NO;
}

- (BOOL)isLowFoilsSituationWillOccure
{
    int blueFoilsCount      = 0;
    int yellowFoilsCount    = 2;
    int whiteFoilsCount     = 0;
    for (DMWaypoint *waypoint in self.waypoints) {
        if ([waypoint.country isUSA])
            yellowFoilsCount += 1;
        else
            if (waypoint.kind & DMWaypointKindTransit)
                blueFoilsCount += 1;
            else
                whiteFoilsCount += 1;
    }
    
    BOOL isBlueLow      = (blueFoilsCount * kLowFoilsStatusTrigger) - kLowFoilsTemporaryDifference > self.foilsBlue;
    BOOL isWhiteLow     = (whiteFoilsCount * kLowFoilsStatusTrigger) - kLowFoilsTemporaryDifference  > self.foilsWhite;
    BOOL isYellowLow    = (yellowFoilsCount * kLowFoilsStatusTrigger) - kLowFoilsTemporaryDifference > self.foilsYellow;
    
    BOOL retValue = (isBlueLow || isWhiteLow || isYellowLow);
    
    if (retValue) {
        [self actualizeAlertWithType:CBSimpleAlertType_Warning_LowFoils
                    withDateInterval:[[NSDate date] timeIntervalSince1970]];
    }
    return (isBlueLow || isWhiteLow || isYellowLow);
}

- (BOOL)isNeedToVerifyCarnet
{
    return !self.flagVerified;
}

- (BOOL)isReconstitueWarningSituation
{
    __block BOOL isNeedToReconstitue = NO;
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *waypointObject, NSUInteger idx, BOOL *stop) {
        if ((self.activeWaypoint.country == waypointObject.country) && (waypointObject != self.activeWaypoint) && (waypointObject.items.count != 0)) {
            isNeedToReconstitue = YES;
            *stop = YES;
        }
    }];
    return isNeedToReconstitue;
}

- (BOOL)isCarnetSplitted
{
    __block BOOL isSplitted = NO;
    [self.items enumerateObjectsUsingBlock:^(DMItem *anItem, BOOL *stop) {
        if (anItem.waypoint != self.activeWaypoint || anItem.splitted) {
            isSplitted = YES;
            *stop = YES;
        }
    }];
    return isSplitted;
}

- (BOOL)isCarnetActive
{
    return self.flagActive;
}

- (BOOL)isContainsLocationRelatedAlert
{
    __block BOOL retValue = NO;
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *wpObject, NSUInteger idx, BOOL *stop) {
        if ([wpObject containsAlerts]) {
            retValue = YES;
            *stop = YES;
        }
    }];
    return retValue;
}

- (void)actualizeAlertWithType:(CBAlertType)aType withDateInterval:(NSTimeInterval)aTimeInterval
{
    DMSimpleAlert *alert = [self alertWithType:aType];
    if (!alert) {
        [self addSimpleAlertWithType:aType showDate:aTimeInterval];
    }
    else
        if ([CBDateConvertionUtils isDayPassedFromTimeInterval:aTimeInterval toTimeInterval:alert.showingDate])
            alert.shown = NO;
}

#pragma mark - Creating New Object

- (void)addItemsFromArray:(NSArray *)itemsArray 
{
    int count = itemsArray.count;
    if (count != 0) {
        for (NSDictionary *dict in itemsArray) {
            DMItem *item = [DMItem newItemWithData:dict carnet:self];
            [self addItemsObject:item];
        }
    }
}

- (void)addTravelPlansFromArray:(NSArray *)travelPlans
{
    int travelPlansCount = travelPlans.count;
    if (travelPlansCount > 0) {
        for (NSDictionary *wpDic in travelPlans) {
            DMWaypoint *waypoint = [DMWaypoint obtainWaypointWithData:wpDic];
            [self addWaypointsObject:waypoint];
        }
        
        [DMManager saveContext];
    }
    
#ifdef DEBUG
    for (DMWaypoint * wp in self.waypoints) {
        DDLogVerbose(@"%@ kind %d status %d", wp.country.name, wp.kind, wp.status);
    }
#endif
}

- (void)createDefaultTravelPlans
{
    DMWaypoint *defaultWaypoint = [DMWaypoint obtainDefaultWaypoint];
    [self addWaypointsObject:defaultWaypoint];
    [DMManager saveContext];
}

- (void)deleteAllItems
{
    [self removeItems:self.items];
}

- (void)deleteAllWaypoints
{
    while ([self.waypoints lastObject]) {
        [self removeWaypointsObject:[self.waypoints lastObject]];
    }
    [self setActiveCarnetsWaypoint:nil];
}

#pragma mark - Obtain Carnet

+ (instancetype)obtainCarnetWithData:(NSDictionary *)carnetData
{
    return [self obtainCarnetWithData:carnetData afterScan:NO];
}

+ (instancetype)obtainCarnetWithData:(NSDictionary *)carnetData afterScan:(BOOL)afterScan
{
    DMCountry *aCountry     = [DMCountry countryByIdentifier:[DMManager countryISO]];
    
    NSString *identifier    = carnetData[keyDMCarnetGUID];
    DMCarnet *carnet        = [DMCarnet carnetByGUID:identifier];
    
    if (carnet) {
    
        carnet.timestamp = carnetData [keyDMCarnetTimestamp];
        
        NSSet *alertsSet        = carnet.activeWaypoint.alerts;
        NSMutableArray *alerts  = [NSMutableArray arrayWithCapacity:alertsSet.count];
        
        for (DMLocationAlert<CBAlertObjectProtocol> *locAlert in alertsSet) {
            NSArray *buttons = [locAlert alertButtons];
            if (!afterScan || !([buttons count] == 1 && [[buttons lastObject] integerValue] == CBAlertButtonType_Scan)) {
                [alerts addObject:[locAlert parametrs]];
            }
        }
        
        // remove old items and waypoints
        [carnet deleteAllItems];
        [carnet deleteAllWaypoints];
        
        // add new items and waypoints
        NSArray *travelPlan = carnetData[keyDMCarnetTravelPlan];

        if ([travelPlan lastObject]) {
            [carnet addTravelPlansFromArray:travelPlan];
        } else {
            [carnet firstTimeScannedInCountry:aCountry];
        }
        
        [carnet scanPerformedInCountry:aCountry afterScan:afterScan];
        
        for (NSDictionary *params in alerts) {
            DMLocationAlert<CBAlertObjectProtocol> *alert = [DMLocationAlert alertFromParametrs:params];
            [carnet.activeWaypoint replaceAlertWithType:[alert type] withAlert:alert];
        }
        
        [carnet addItemsFromArray:carnetData[keyDMCarnetItems]];
        
        [carnet refreshCarnetStatus];
    }
    else {
        carnet = [DMCarnet newCarnetWithData:carnetData];
        [carnet firstTimeScannedInCountry:aCountry];
        
        [DMManager logServerAction:DMLoggedActionTypeVerify
                      withComments:[NSString stringWithFormat:@"Carnet with ID %@ is needed to be verified", carnet.identifier]
                         forCarnet:carnet];
    }
    
    [DMManager saveContext];
    [DMManager postRefreshNotification];

    return carnet;
}

#pragma mark - Auxilliary Methods

- (NSNumber *)totalItemsValue
{
	return [self.items valueForKeyPath:@"@sum.value"];
}

- (NSUInteger)itemsCount
{
    NSExpression *quantLeftExpression   = [NSExpression expressionForKeyPath:@"quantity"];
    NSExpression *quantRightExpression  = [NSExpression expressionForConstantValue:@0];
    NSPredicate *quantPredicate         = [NSComparisonPredicate predicateWithLeftExpression:quantLeftExpression
                                                                     rightExpression:quantRightExpression
                                                                            modifier:NSDirectPredicateModifier
                                                                                type:NSGreaterThanPredicateOperatorType
                                                                             options:NSNormalizedPredicateOption];
    NSPredicate *compPred   = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[quantPredicate]];
    NSSet *filteredSet      = [self.items filteredSetUsingPredicate:compPred];
    
    return filteredSet.count;
}

#pragma mark - Waypoints

- (NSComparator)waypointsComparator
{
    return ^NSComparisonResult(DMWaypoint *waypoint1, DMWaypoint *waypoint2) {
        
        if (waypoint1.kind & DMWaypointKindStartpoint) {
            return NSOrderedAscending;
        }
        
        if (waypoint2.kind & DMWaypointKindStartpoint) {
            return NSOrderedDescending;
        }
        
        DMWaypointStatus status1 = [waypoint1 status];
        DMWaypointStatus status2 = [waypoint2 status];
        
        if ((status1 == DMWaypointStatusPassed) && (status2 == DMWaypointStatusQueued)) {
            return NSOrderedAscending;
        } else if ((status1 == DMWaypointStatusQueued) && (status2 == DMWaypointStatusPassed)) {
            return NSOrderedDescending;
        } else {
            NSTimeInterval interval1 = [waypoint1 dateArrival];
            NSTimeInterval interval2 = [waypoint2 dateArrival];
            
            if (interval1 > interval2) {
                return NSOrderedDescending;
            } else if (interval2 > interval1) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }
    };
}

- (void)removeWaypoint:(DMWaypoint *)waypoint
{
    [self removeWaypointsObject:waypoint];
}

- (DMWaypoint *)obtainWaypointByIndex:(int16_t)index
{
    return [self.waypoints objectAtIndex:index];
}

- (DMWaypoint *)obtainProcessedWaypointByCountryID:(NSString *)countryID
{
    __block DMWaypoint *retWaypoint = nil;
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *waypointObj, NSUInteger idx, BOOL *stop) {
        if ([waypointObj.country.identifier isEqualToString:countryID] && waypointObj.status == DMWaypointStatusPassed) {
            retWaypoint = waypointObj;
            *stop = YES;
        }
    }];
    return retWaypoint;
}

#pragma mark - Items

- (NSArray *)obtainSplittedItemsForWaypoint:(DMWaypoint *)waypoint
{
    __block NSMutableArray *objects = [[NSMutableArray alloc] init];
    for (DMWaypoint *waypointObject in self.waypoints) {
        if ((waypoint.country == waypointObject.country) && (waypointObject != waypoint)) {
            [objects addObjectsFromArray:[waypointObject.items allObjects]];
        }
    }
    return @[objects];
}

@end

@implementation DMCarnet (TravelFlow)

#pragma mark *Public

- (BOOL)isAlreadyDepartedUSA
{
    return (!(self.activeWaypoint.kind & DMWaypointKindStartpoint));
}

- (BOOL)isTravelFinished
{
    /* active waypoint should be changed already */
    return ([self.activeWaypoint.country isUSA] && self.activeWaypoint == [self.waypoints lastObject] && (self.waypoints.count > 1));
}

- (BOOL)isWaypointWithCountryWasPlannedNext:(DMCountry *)aCountry
{
    NSInteger activeIndex = [self.waypoints indexOfObject:self.activeWaypoint];
    NSInteger nextIndex   = activeIndex + 1;
    if (self.waypoints.count < 2 || !aCountry || nextIndex >= self.waypoints.count)
        return NO;
    
    DMWaypoint *nextWP = [self.waypoints objectAtIndex:nextIndex];
    return [nextWP.country isEqual:aCountry];
}

- (void)forceSetActiveWaypoint
{
    __block BOOL retValue = NO;
    if (!self.activeWaypoint) {
        [[self.waypoints reversedOrderedSet] enumerateObjectsUsingBlock:^(DMWaypoint *wp, NSUInteger idx, BOOL *stop) {
            if (wp.status == DMWaypointStatusPassed) {
                [self setActiveCarnetsWaypoint:wp];
                retValue = YES;
                *stop = YES;
            }
        }];
    }
    
    if (!retValue)
        [self setActiveCarnetsWaypoint:self.waypoints[0]];
}

- (void)refreshTravelStateForDate:(NSDate *)aDate
{
    if (self.flagActive)
        return;
    
    if ([CBDateConvertionUtils isDayPassedFromTimeInterval:[aDate timeIntervalSinceReferenceDate]
                                            toTimeInterval:self.activeWaypoint.dateDeparture]
        || !self.activeWaypoint.dateDeparture)
    {
        if ([[DMCarnet obtainActiveCarnets] count] > 1) {
            [self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Accompany
                                                 showDate:[aDate timeIntervalSinceReferenceDate]];
        }
        
        [self refreshCarnetStatus];
        [DMManager saveContext];
        [DMManager postRefreshNotification];
        
    }
}

- (void)refreshStateWithCountry:(DMCountry *)aCountry
{
    [aCountry setAlertShown:NO];
    [aCountry refreshCountryState];
    
    [self refreshRouteWithCountry:aCountry];
    [DMManager updateServerForCarnet:self];
}

- (void)refreshStateForAirport:(DMCheckpoint *)anCheckpoint
{
    [anCheckpoint setAlertShown:NO];
    [anCheckpoint refreshAlertState];
    
    [self refreshRouteWithCountry:anCheckpoint.country];
    [DMManager updateServerForCarnet:self];
}


- (void)moveUnsplittedItems
{
    for (DMItem *itemObj in self.items) {
        if (itemObj.splitted == NO)
            itemObj.waypoint = self.activeWaypoint;
    }
    
    [DMManager saveContext];
}

- (void)clearActiveWaypointCustoms
{
    [self clearActiveWaypointCustomsAfterScan:NO];
}

- (void)clearActiveWaypointCustomsAfterScan:(BOOL)afterScan
{
    if (!afterScan) {
        [self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Scan];
        [DMManager logServerAction:DMLoggedActionTypeRescanPrompt
                      withComments:@"Promt to rescan"
                         forCarnet:self];
    }
    [self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Validation];
}

- (void)clearFinishingWaypointCustoms
{
    [self clearFinishingWaypointCustomsAfterScan:NO];
}

- (void)clearFinishingWaypointCustomsAfterScan:(BOOL)afterScan
{
    if (!afterScan) {
        [self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Scan];
        [DMManager logServerAction:DMLoggedActionTypeRescanPrompt
                      withComments:@"Promt to rescan"
                         forCarnet:self];
    }
    
    [self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Validation];
//    [self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Remove_USA];
}

- (void)performArrivalWorkflow
{
    [self performArrivalWorkflowAfterScan:NO];
}

- (void)performArrivalWorkflowAfterScan:(BOOL)afterScan
{
    if ([self isTravelFinished]) {
        [self clearFinishingWaypointCustomsAfterScan:afterScan];
    }
    else {
        [self clearActiveWaypointCustomsAfterScan:afterScan];
    }
}

- (void)performCarnetActivation
{
    if ([[DMCarnet obtainActiveCarnets] count] > 1) {
        [self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Accompany];
    }
}

- (void)performDepartingWorkflow
{
    if (self.activeWaypoint.kind & DMWaypointKindStartpoint) {
        //With ticket 79477954 add alert to carnet, not waypoint >>>
        //[self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Validation_US];
        // ===
        NSTimeInterval currentInterval  = [[NSDate date] timeIntervalSinceReferenceDate];
        [self addSimpleAlertWithType:CBLocationAlertType_Validation_US showDate:currentInterval];
        // <<<
    } else {
        [self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Stamp];
    }
    
    if (!([self.createOnDevice timeIntervalSinceNow] < 0 && [self.createOnDevice timeIntervalSinceNow] > -200)) {
        [self.activeWaypoint addLocationAlertWithType:CBLocationAlertType_Scan];
    }
}

- (void)firstTimeScannedInCountry:(DMCountry *)aCountry
{
    [self addSimpleAlertWithType:CBSimpleAlertType_Warning_Verify];
    [self addSimpleAlertWithType:CBSimpleAlertType_Warning_Signed];
    
    [self performStartpointValidationWithCountry:aCountry];
    [self refreshRouteWithCountry:aCountry];
    
    [DMManager updateServerForCarnet:self];
    [DMManager saveContext];
    [DMManager postRefreshNotification];
}

- (void)scanPerformedInCountry:(DMCountry *)aCountry
{
    [self scanPerformedInCountry:aCountry afterScan:NO];
}

- (void)scanPerformedInCountry:(DMCountry *)aCountry afterScan:(BOOL)afterScan
{
    [self refreshRouteWithCountry:aCountry afterScan:afterScan];
    [DMManager updateServerForCarnet:self];
}

- (void)takeAllItemsFromWaypoint:(DMWaypoint *)aWaypoint
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)reconstitueAllItemsForWaypoint:(DMWaypoint *)aWaypoint
{
    NSArray *items = [self obtainSplittedItemsForWaypoint:aWaypoint];
    [DMManager reconstituteCarnets:self items:items atWaypoint:aWaypoint completionHandler:nil];
}

- (void)moveCarnetToNextWaypoint
{
    [self moveCarnetToNextWaypointAfterScan:NO];
}

- (void)moveCarnetToNextWaypointAfterScan:(BOOL)afterScan
{
    DMWaypoint *nextWP;
    NSInteger activeIndex   = [self.waypoints indexOfObject:self.activeWaypoint];
    nextWP                  = [self.waypoints objectAtIndex:activeIndex + 1];
    [self setActiveCarnetsWaypoint:nextWP];
    [self moveUnsplittedItems];
    [self performArrivalWorkflowAfterScan:afterScan];
}

- (void)moveCarnetToInsertedWaypoint:(DMWaypoint *)aWaypoint
{
    aWaypoint.containsError    = YES;
    [aWaypoint addLocationAlertWithType:CBLocationAlertType_Wrong_Country];
    
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqual:aWaypoint]) {
            *stop = YES;
        }
        if (obj.status == DMWaypointStatusQueued) {
            [obj addLocationAlertWithType:CBLocationAlertType_UnknowError];
        }
    }];
    
    [self setActiveCarnetsWaypoint:aWaypoint];
    [self moveUnsplittedItems];
    [self performArrivalWorkflow];

}

- (void)skipCarnetToWaypoint:(DMWaypoint *)aWaypoint
{    
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqual:aWaypoint]) {
            *stop = YES;
        }
        if (obj.status == DMWaypointStatusQueued) {
            [obj addLocationAlertWithType:CBLocationAlertType_UnknowError];
        }
    }];
    
    [self setActiveCarnetsWaypoint:aWaypoint];
    [self moveUnsplittedItems];
    [self performArrivalWorkflow];
}

- (void)refreshRouteWithCountry:(DMCountry *)aCountry
{
    [self refreshRouteWithCountry:aCountry afterScan:NO];
}

- (void)refreshRouteWithCountry:(DMCountry *)aCountry afterScan:(BOOL)afterScan
{
    if ([self.activeWaypoint.country isEqual:aCountry]) {
        if (self.flagActive) {
            if (!afterScan) {
                [self performDepartingWorkflow];
            }
        } else {
            [self performCarnetActivation];
        }
        
        return;
    }
    
    DMWaypoint *active = self.activeWaypoint;
    if (!active) {
        active = [self dateRelatedWaypointWithStatus:DMWaypointStatusPassed];
        [self setActiveCarnetsWaypoint:active];
    }
    
    if (!active) {
        [self forceSetActiveWaypoint];
        active = self.activeWaypoint;
    }
    
    DMCountry *actualCountry = (aCountry ? aCountry : active.country);

    if ([active.country isEqual:actualCountry]) {
		[self moveUnsplittedItems];
        if (!self.flagActive) {
            if (!afterScan) {
                [self performDepartingWorkflow];
            }
        }
        return;
    }
    
// at this point no departing cannot be performed. Should move to new waypoint
    
    //waypoint was planned next
    if ([self isWaypointWithCountryWasPlannedNext:actualCountry]) {
        [self moveCarnetToNextWaypointAfterScan:afterScan];
        return;
    }
    
    //waypoint wasn't planned next, but was planned at this date]
    DMWaypoint *skippedToWp = [self dateRelatedWaypointWithStatus:DMWaypointStatusQueued];
    if ([skippedToWp.country isEqual:actualCountry]) {
        [self skipCarnetToWaypoint:skippedToWp];
        
        [DMManager logServerAction:DMLoggedActionTypeWrongCountry
                      withComments:[NSString stringWithFormat:@"%@ was not planned as next country to visit", actualCountry.name]
                         forCarnet:self];
        return;
    }
    
    //waypoint wasn't planned at this date at all
    
    DMWaypoint *insertedWP = [DMManager insertWaypointForCarnet:self
                                                    withISOCode:actualCountry.identifier
                                                    arrivalDate:[NSDate date]
                                                           kind:(actualCountry.supportsCarnet ? DMWaypointKindVisit : DMWaypointKindTransit)
                                                         status:DMWaypointStatusPassed];
    [DMManager logServerAction:DMLoggedActionTypeWrongCountry
                  withComments:[NSString stringWithFormat:@"%@ was not planned to visit at all", actualCountry.name]
                     forCarnet:self];
    
    [self moveCarnetToInsertedWaypoint:insertedWP];
}

- (DMWaypoint *)dateRelatedWaypointWithStatus:(DMWaypointStatus)aStatus
{
    NSDate *date = [NSDate date];
    
    __block DMWaypoint *waypoint    = nil;
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isActiveAtDate:date] && obj.status == aStatus) {
            waypoint = obj;
            *stop = YES;
        }
    }];
    return waypoint;
}

#pragma mark * Private

- (void)performStartpointValidationWithCountry:(DMCountry *)aCountry
{
    DMWaypoint *startpoint = nil;
    
    if (!self.waypoints.count) {
        NSDate *prevDate    = [CBDateConvertionUtils addDays:-1 toDate:[NSDate date]];
        
        startpoint = [DMManager insertWaypointForCarnet:self
                                                        withISOCode:@"US"
                                                        arrivalDate:prevDate
                                                               kind:DMWaypointKindStartpoint
                                                             status:DMWaypointStatusPassed];
        
        if (![aCountry isUSA]) {
            [startpoint addLocationAlertWithType:CBLocationAlertType_UnknowError];
            startpoint.containsStartpointIssue = YES;
        }
        
        return;
    }
    
    DMWaypoint *firstWaypoint = self.waypoints[0];
    
    if ([firstWaypoint.country isUSA])
        return;
    
    NSDate *arrivalDate     = [NSDate dateWithTimeIntervalSince1970:firstWaypoint.dateArrival];
    NSDate *previousDate    = [CBDateConvertionUtils addDays:-1 toDate:arrivalDate];
    
    startpoint  = [DMManager insertWaypointForCarnet:self
                                         withISOCode:@"US"
                                         arrivalDate:previousDate
                                                kind:DMWaypointKindStartpoint
                                              status:DMWaypointStatusPassed];
    [startpoint addLocationAlertWithType:CBLocationAlertType_UnknowError];
}

- (BOOL)isCarnetPossiblyBeAlreadyActiveConsideringDate:(NSDate *)aDate
{
    __block BOOL retVal = NO;
    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *waypoint, NSUInteger idx, BOOL *stop) {
        NSDate *waypointDate = [NSDate dateWithTimeIntervalSinceReferenceDate:waypoint.dateArrival];
        if ([waypointDate earlierDate:aDate]) {
            retVal = YES;
            *stop = YES;
        }
    }];
    return retVal;
}

@end

@implementation DMCarnet (WaypointsAuxilliary)

- (NSString *)nextCountryNameForWaypoint:(DMWaypoint *)aWaypoint
{
    NSString *retString = @"next country";
    NSInteger wpIndex   = [self.waypoints indexOfObject:aWaypoint];
    NSInteger nextIndex = wpIndex + 1;
    if (nextIndex + 1 < self.waypoints.count) {
        retString = ((DMWaypoint *)[self.waypoints objectAtIndex:nextIndex]).country.name;
    }
    return retString;
}

//- (DMWaypoint *)waypointByKind:(DMWaypointKind)aKind
//{
//    __block DMWaypoint *wpObject = nil;
//    [self.waypoints enumerateObjectsUsingBlock:^(DMWaypoint *wp, NSUInteger idx, BOOL *stop) {
//        if (wp.kind == aKind) {
//            wpObject    = wp;
//            *stop       = YES;
//        }
//    }];
//    return wpObject;
//}
@end
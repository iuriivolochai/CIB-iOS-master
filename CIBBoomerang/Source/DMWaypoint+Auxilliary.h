//
//  DMWaypoint+Auxilliary.h
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 4/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMWaypoint.h"
#import "DMManager.h"

FOUNDATION_EXPORT NSString *const keyDMWaypointParsingCountryId;
FOUNDATION_EXPORT NSString *const keyDMWaypointParsingDate;
FOUNDATION_EXPORT NSString *const keyDMWaypointParsingKind;
FOUNDATION_EXPORT NSString *const keyDMWaypointParsingStatus;

FOUNDATION_EXPORT NSString *const keyDMWaypointArrivalDate;
FOUNDATION_EXPORT NSString *const keyDMWaypointDepartureDate;
FOUNDATION_EXPORT NSString *const keyDMWaypointObjectID;

@interface DMWaypoint (Auxilliary)

/* Obtaining waypoint object */
/* Obtaining new waypoint object 
    countryId       - country identifier (e.g. "US") *required,
    arrivalDate     - arrival date to current waypoint *required,
    departureDate   - departure date from current waypoint *optional
    kind            - specifies waypoint special kind (error, start, end, transit, visit) *required
    status          - specifies waypoint visiting status (queued, active, visited) *required
 */
+ (DMWaypoint *)obtainWaypointObjectWithCountryID:(NSString *)countryID
                                      arrivalDate:(NSDate *)arrivalDate
                                     depatureDate:(NSDate *)departureDate
                                             kind:(DMWaypointKind)kind
                                           status:(DMWaypointStatus)status;

/* Obtaining new waypoint from NSDictionary with keys:
    @"CountryId"    - country identifier (e.g. "US"),
    @"Date"         - arriving date to current waypoint,
    @"Kind"         - specifies waypoint special kind (error, start, end, transit, visit)
    @"Processed"    - specifies waypoint visiting status (false == queued, true == visited)
 */
+ (DMWaypoint *)obtainWaypointWithData:(NSDictionary *)data;

/* Obtaining new default waypoint */
+ (DMWaypoint *)obtainDefaultWaypoint;

/* Waypoint Alerts */
/* return if carnet has alerts at this waypoint */
- (BOOL)containsAlerts;
/* return if carnet has error at this waypoint */
- (BOOL)containsErrors;
///* show location dependent popover */
- (BOOL)containsOnlyPopovers;
//- (BOOL)containsPopoverAlerts;
/* obtain location alerts sorted by priority */
//- (void)obtainLocationAlerts:(void (^)(NSArray *alerts, NSArray *popovers))completion;

- (NSDictionary *)parametrsForPatch;

/**
 *  @method                 activeWaypointsWithDepartureDate:
 *  @abstract               return array of active waypoints, that scheduled to be departed at specific date
 *  @param aDepartureDate   - NSDate object
 *
 *  @return                 array of the waypoints, if exist, may return empty array
 */
+ (NSArray *)activeWaypointsWithDepartureDate:(NSDate *)aDepartureDate;

/**
 *  @method getAlertsArray
 *
 *  @return NSArray of location alerts
 */
- (NSArray *)getAlertsArray;
- (NSArray *)popoversAlerts;

/**
 *  @method     addLocationAlertWithType:
 *  @abstract   adds non-repeat Location alert
 *  @param aType CBAlertType enum
 */
- (void)addLocationAlertWithType:(CBAlertType)aType;

/**
 *  @method                 addLocationAlertWithType:showDate:
 *  @abstract               adds recuuretn Location Alert Object
 *  @param aType            CBAlertType enum
 *  @param aTimeInterval    NSTimeInterval to show location alert at
 */
- (void)addLocationAlertWithType:(CBAlertType)aType showDate:(NSTimeInterval)aTimeInterval;

/**
 *
 *  @method     alertWithType:
 *  @abstract   returns DMLocationObject of specified type
 *  @param      aType - CBAlertType enum
 *
 *  @return     DMLocationAlert object
 */
- (DMLocationAlert *)alertWithType:(CBAlertType)aType;

- (BOOL)isActiveAtDate:(NSDate *)aDate;

- (void)replaceAlertWithType:(CBAlertType)aType withAlert:(DMLocationAlert *)anAlert;

@end

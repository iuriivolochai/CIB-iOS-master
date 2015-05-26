//
//  DMCarnet+Auxilliary.h
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 4/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMCarnet.h"
#import "DMManager.h"

FOUNDATION_EXPORT NSString * const keyDMCarnetAccountNumber;
FOUNDATION_EXPORT NSString * const keyDMCarnetDateExpired;
FOUNDATION_EXPORT NSString * const keyDMCarnetDateIssued;
FOUNDATION_EXPORT NSString * const keyDMCarnetFoilsBlue;
FOUNDATION_EXPORT NSString * const keyDMCarnetFoilsWhite;
FOUNDATION_EXPORT NSString * const keyDMCarnetFoilsYellow;
FOUNDATION_EXPORT NSString * const keyDMCarnetIdentifier;
FOUNDATION_EXPORT NSString * const keyDMCarnetIssuedBy;
FOUNDATION_EXPORT NSString * const keyDMCarnetTimestamp;
FOUNDATION_EXPORT NSString * const keyDMCarnetTravelPlan;
FOUNDATION_EXPORT NSString * const keyDMCarnetVerified;
FOUNDATION_EXPORT NSString * const keyDMCarnetDeviceId;

FOUNDATION_EXPORT NSString *const keyGatewayItems;
FOUNDATION_EXPORT NSString *const keyGatewayTravelPlan;

@interface DMCarnet (Auxilliary)

/**
 *  @method     obtainCarnetWithData:
 *  @abstract   creates new DMCarnet NSManagedObject with parametrs from NSDictionary
 *  @param      carnetData
 *
 *  @return DMCarnet object
 */
+ (instancetype)obtainCarnetWithData:(NSDictionary *)carnetData;
+ (instancetype)obtainCarnetWithData:(NSDictionary *)carnetData afterScan:(BOOL)afterScan;

+ (NSDate *)nextTravelDateAfterDate:(NSDate *)aFiredDate;

/**
 *  @method     setCarnetActive:
 *  @abstract   sets DMCarnet in Active state
 *  @param isActive BOOL    isActive flag detects if DMCarnet will be used in next travell
 */
- (void)setCarnetActive:(BOOL)isActive;

/**
 *  @method     setCarnetVerified:
 *  @abstract   sets DMCarnet verified flag to YES
 *  @param isVerified BOOL  isVerified flag detects if DMCarnet has passed verifiing process
 */
- (void)setCarnetVerified:(BOOL)isVerified;

- (void)setActiveCarnetsWaypoint:(DMWaypoint *)aWaypoint;
/**
 *  @method     refreshCarnetStatus
 *  @abstract   refreshes status of the DMCarnet, actual status should be obtained by carnet.carnetStatus getter
 */
- (void)refreshCarnetStatus;

/**
 *  @method     totalItemsValue
 *  @return     NSNumber object - total value of all carnet's items
 */
- (NSNumber *)totalItemsValue;

/**
 *  @method     totalItemsValue
 *  @return     NSUInteger      - items count
 */
- (NSUInteger)itemsCount;

/* additional flags to set expiring text color when displaying carnet information */
- (BOOL)isCarnetExpirationSituationOccured;
- (BOOL)isCarnetExpirationSitutationWillOccure;
- (NSString *)alertCountryISO;
- (NSString *)errorCountryISO;

/**
 *  @method     obtainWaypointByIndex:
 *  @abstract   returns DMWaypoint object for index
 *  @param      index   - index of the waypoint in carnet route set
 *  @return     DMWaypoint object
 */
- (DMWaypoint *)obtainWaypointByIndex:(int16_t)index;

/**
 *  @method             obtainProcessedWaypointByCountryID:
 *  @abstract           returns ANY passed waypoint with specified country
 *  @discussion         if NO specified waypoint will be found, than method will return nil
 *  @param countryID    country ISO Code, must not be nil
 *  @return DMWaypoint object,
 */
- (DMWaypoint *)obtainProcessedWaypointByCountryID:(NSString *)countryID;

/**
 *  @method             addWaypointsObject:
 *  @abstract           adds aWaypoint object and triggers waypoints set sorting
 *  @param aWaypoint    DMWaypoint object to add
 */
- (void)addWaypointsObject:(DMWaypoint *)aWaypoint;

/**
 *  @method             removeWaypoint:
 *  @abstract           deletele aWaypoint object and triggers waypoints set sortring
 *  @param aWaypoint    DMWaypoint object to remove
 */
- (void)removeWaypoint:(DMWaypoint *)aWaypoint;

/**
 *  @method             isTravelScheduledForDate:
 *  @abstract           method detects if any carnet is scheduled for travel this day
 *  @param aTravelDate  NSDate objectm, must not be nil
 */
+ (BOOL)isTravelScheduledForDate:(NSDate *)aTravelDate;

/**
 *  @method     obtainActiveCarnets
 *  @abstract   returns DMCarnets scheduled to departure
 *  @return     NSArray of the DMCarnet objects with isActive == YES, may return empty array
 */
+ (NSArray *)obtainActiveCarnets;

/**
 *  @method     obtainAllCarnets
 *  @abstract   returns all DMCarnets objects
 *  @return NSArray of the all DMCarnet objects
 */
+ (NSArray *)obtainAllCarnets;
/*
    Obtaining parametrs for carnet updating from carnet
 */

- (NSDictionary *)patchParametersWithSplittingData:(NSArray *)splittingItems;

/**
 *  @method         getAlertsArray
 *  @abstract       returns array of the simple alerts
 *  @return NSArray - array of the simple alerts, if there is no simple alerts to show will return empty array
 */
- (NSArray *)getAlertsArray;

/**
 *  @method         getPopoversArray
 *  @abstract       return array of the popovers alerts
 *  @return NSArray - array of the popovers alert, if there is no popovers alert to show will return empty array
 */
- (NSArray *)getPopoversArray;

/**
 *  @method     containsLocationAlerts
 *  @return     returns if any of carnet waypoints contains location alerts
 */
- (BOOL)containsLocationAlerts;

/**
 *  @method             handleButtonWithTypeTapped:forSimpleAlertWithType:
 *  @abstract           returns DMManagerAlertHandlingAction enum for alert object
 *  @param aButtonType  CBAlertType  enum NSUInteger
 *  @param anAlertType  CBAlertButtonType enum NSUInteger
 *
 *  @return DMManagerAlertHandlingAction enum NSUInteger
 */
- (DMManagerAlertHandlingAction)handleButtonWithTypeTapped:(CBAlertButtonType)aButtonType forSimpleAlertWithType:(CBAlertType)anAlertType;

/**
 *  @method             handleButtonWithTypeTapped:forLocationAlertWithType:atWaypoint:
 *  @abstract           returns DMManagerAlertHandlingAction enum for alert object
 *  @param aButtonType  CBAlertButtonType enum NSUInteger
 *  @param anAlertType  CBAlertType  enum NSUInteger
 *  @param aWaypoint    DMWaypoint to which alert is related
 *  @return             DMManagerAlertHandlingAction enum NSUInteger
 */
- (DMManagerAlertHandlingAction)handleButtonWithTypeTapped:(CBAlertButtonType)aButtonType forLocationAlertWithType:(CBAlertType)anAlertType atWaypoint:(DMWaypoint *)aWaypoint;


- (NSArray *)informationAlerts;

@end

@interface DMCarnet (TravelFlow)

- (BOOL)isAlreadyDepartedUSA;
- (BOOL)isTravelFinished;

- (void)clearActiveWaypointCustoms;
- (void)clearFinishingWaypointCustoms;

- (void)performArrivalWorkflow;
- (void)performCarnetActivation;
- (void)performDepartingWorkflow;

- (void)refreshStateForAirport:(DMCheckpoint *)anAirport;
- (void)refreshStateWithCountry:(DMCountry *)aCountry;
- (void)refreshTravelStateForDate:(NSDate *)aDate;
- (void)refreshRouteWithCountry:(DMCountry *)aCountry afterScan:(BOOL)afterScan;

- (void)reconstitueAllItemsForWaypoint:(DMWaypoint *)aWaypoint;
- (void)takeAllItemsFromWaypoint:(DMWaypoint *)aWaypoint;

- (void)firstTimeScannedInCountry:(DMCountry *)aCountry;
- (void)scanPerformedInCountry:(DMCountry *)aCountry;
- (void)scanPerformedInCountry:(DMCountry *)aCountry afterScan:(BOOL)afterScan;

- (void)moveCarnetToNextWaypoint;
- (void)moveCarnetToInsertedWaypoint:(DMWaypoint *)aWaypoint;
- (void)skipCarnetToWaypoint:(DMWaypoint *)aWaypoint;

@end

@interface DMCarnet (WaypointsAuxilliary)

- (NSString *)nextCountryNameForWaypoint:(DMWaypoint *)aWaypoint;
//- (DMWaypoint *)waypointByKind:(DMWaypointKind)aKind;

@end


//
//  DMManager.h
//  PwC
//
//  Created by Roman on 2/26/13.
//  Copyright (c) 2013 Roman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "CBServerLoggingUtils.h"

#import "DMCheckpoint.h"
#import "DMCarnet+Auxilliary.h"
#import "DMCountry+Auxilliary.h"
#import "DMItem+Auxilliary.h"
#import "DMLocationAlert+Auxilliary.h"
#import "DMSimpleAlert+Auxilliary.h"
#import "DMWaypoint+Auxilliary.h"


FOUNDATION_EXPORT NSString *const DMNotificationTypeAirportInsctructionsReceived;
FOUNDATION_EXPORT NSString *const DMNotificationTypeLocationServicesDisabled;
FOUNDATION_EXPORT NSString *const DMNotificationTypeLocationError;
FOUNDATION_EXPORT NSString *const DMNotificationTypeTravellingStateRefreshed;
FOUNDATION_EXPORT NSString *const DMNotificationTypeWillYouBeTravellingSoon;
FOUNDATION_EXPORT NSString *const keyDMNotificationHeader;
FOUNDATION_EXPORT NSString *const keyDMNotificationInstructions;
FOUNDATION_EXPORT NSString *const keyDMNotificationText;
FOUNDATION_EXPORT NSString *const keyUserDefaultsFirstAppLaunch;

typedef void (^DMManagerCarnetDownloadCompletionHandler)(DMCarnet *carnet, NSError *error);
typedef void (^DMManagerUpdateCompletionHandler)        (NSString *timeStamp, NSError *error);
typedef void (^DMManagerLoggingCompletionHandler)       (BOOL willLogged, NSString *loggingAction);
typedef void (^DMManagerLoadAlertsCompletionHandler)    (NSDictionary *alertsDic, BOOL isErrorOccured);


@interface DMManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DMManager *)sharedManager;
+ (NSManagedObjectContext *)managedObjectContext;
+ (void)saveContext;

+ (void)preloadCountries;
+ (void)loadLocations;
+ (void)cleanDublicates;

@end

@interface DMManager (Carnets)

+ (void)updateLocalCarnetsForCurrentCountry;

/**
 *  @method                     addWaypointForCarnet:withCountryIdentifier:departureDate:kind:status:
 *  @abstract                   add waypoint to the carnet route list
 *  @discussion                 Add Waypoiny object of transit, visit or none kind (in case we adding USA waypoint). DMManager then decides where to put waypoint object and how to sort them.
 *  @param aCarnet              DMCarnet object. Waypoint object will be added to it's waypoint route
 *  @param aCountryIdentifier   country ISO Code
 *  @param aDepartureDate       departure date to this waypoint
 *  @param aKind                waypoint kind (view controller can pass only visit or transit; error, startpoint and endpoint can be installed by DMManager if neccessary)
 *  @param aStatus              waypoint status (Passed, Queued)
 */
+ (void)addWaypointForCarnet:(DMCarnet *)aCarnet withCountryIdentifier:(NSString *)aCountryIdentifier departureDate:(NSDate *)aDepartureDate kind:(DMWaypointKind)aKind status:(DMWaypointStatus)aStatus;

/**
 *  @method                 insertWaypointForCarnet:withISOCode:arrivalDate:kind:status:
 *  @abstract               retutns newly created DMWaypoint object
 *  @param aCarnet          DMCarnet object. Waypoint object will be added to it's waypoint route
 *  @param anISOCode        country ISO Code
 *  @param anArrivalDate    arrival date to this waypoint
 *  @param aKind            waypoint kind (view controller can pass only visit or transit; error, startpoint and endpoint can be installed by DMManager if neccessary)
 *  @param aStatus          waypoint status (Passed, Queued)
 *
 *  @return DMWaypoint Object
 */
+ (DMWaypoint *)insertWaypointForCarnet:(DMCarnet *)aCarnet withISOCode:(NSString *)anISOCode arrivalDate:(NSDate *)anArrivalDate kind:(DMWaypointKind)aKind status:(DMWaypointStatus)aStatus;

/**
 *  @method         setCarnet:active:
 *  @abstract       setting carnet's isActive flag
 *  @discussion     carnet's isActive flag detects will be carnet used in next travel
 *  @param aCarnet  DMCarnet object, must not be nil
 *  @param isActive active flag means that carnet will be used in the nearest travel
 */
+ (void)setCarnet:(DMCarnet *)aCarnet active:(BOOL)isActive;

/**
 *  @method         removeCarnet:
 *  @abstract       remove carnet object
 *  @discussion     methods remove carnet object from local database and sends 'DELETE' request to server
 *  @param aCarnet  DMCarnet object to remove;
 */
+ (void)removeCarnet:(DMCarnet *)aCarnet;

+ (void)rejectCarnet:(DMCarnet *)aCarnet;

/**
 *  @method             removeWaypoint:
 *  @abstract           remove DMWaypoint object from appropriate DMCarnet route list
 *  @discussion         methods remove DMWaypoint object and sends 'TRAVEL_PLAN_DELETE' logging message on the server
 *  @param aWaypoint    DMWaypoint object to remove
 */
+ (void)removeWaypoint:(DMWaypoint *)aWaypoint;

/**
 *  @method             verifyCarnet
 *  @abstract           set carnet's isVerified flag to YES (default NO)
 *  @param carnet       DMCarnet object to be verified
 */
+ (void)verifyCarnet:(DMCarnet *)carnet;

/**
 *  @method         carnetQRScanSucceed
 *  @abstract       informs DMManager that scanning succesfully finished
 *  @param aGUID    GUID of the carnet
 */
+ (void)carnetQRScannedWithGUID:(NSString *)aGUID;

/**
 *  @method         refreshCarnetsStatuses
 *  @abstract       refreshes ALL carnet objects 
 */
+ (void)refreshCarnetsStatuses;

@end

@interface DMManager (SplitManaging)

+ (void)acceptAllSplittingChangesForCarnet:(DMCarnet *)carnet
						 completionHandler:(CBSimpleCompletionBlock)completionHandler;

+ (void)reconstituteCarnets:(DMCarnet *)carnet
                       item:(DMItem *)item
				 atWaypoint:(DMWaypoint *)waypoint
		  completionHandler:(CBSimpleCompletionBlock)completionHandler;

+ (void)reconstituteCarnets:(DMCarnet *)carnet
                      items:(NSArray *)items
				 atWaypoint:(DMWaypoint *)waypoint
		  completionHandler:(CBSimpleCompletionBlock)completionHandler;

+ (void)rollbackAllSplittingChangesForCarnet:(DMCarnet *)carnet
						   completionHandler:(CBSimpleCompletionBlock)completionHandler;

+ (void)splitCarnets:(DMCarnet *)carnet
                item:(DMItem *)item
		  atWaypoint:(DMWaypoint *)waypoint
   completionHandler:(CBSimpleCompletionBlock)completionHandler;

@end

@interface DMManager (Gateway)

+ (void)loadAlertForAirportWithID:(NSString *)anID
                completionHandler:(DMManagerLoadAlertsCompletionHandler)completionHandler;

+ (void)loadAlertForCountryWithISOCode:(NSString *)anISOCode
                completionHandler:(DMManagerLoadAlertsCompletionHandler)completionHandler;

+ (void)loadAlertsWithCompletionHandler:(DMManagerLoadAlertsCompletionHandler)completionHandler;

+ (void)loadCarnetWithGUID:(NSString *)guid
		 completionHandler:(DMManagerCarnetDownloadCompletionHandler)completionHandler;

+ (void)loadCarnetWithGUID:(NSString *)GUID
                 afterScan:(BOOL)afterScan
         completionHandler:(DMManagerCarnetDownloadCompletionHandler)completionHandler;

+ (void)updateCarnetWithGUID:(NSString *)guid
				  parameters:(NSDictionary *)params
		   completionHandler:(DMManagerUpdateCompletionHandler)completionHandler;

+ (void)updateServerForCarnet:(DMCarnet *)aCarnet;

@end

@interface DMManager (Notifications)

+ (void)scheduleReminderNotificationForCarnet:(DMCarnet *)carnet afterDaysPassed:(int)daysCount;
+ (void)scheduleTravelDayNotification:(NSDate *)travelDay;
+ (void)travelDayDetected:(NSDate *)travelDay;

+ (void)postRefreshNotification;

@end

@interface DMManager (Alerts)

+ (DMManagerAlertHandlingAction)handlingActionForSimpleAlertWithType:(CBAlertType)anAlertType
                                                       buttonPressed:(CBAlertButtonType)aButtonType
                                                           forCarnet:(DMCarnet *)aCarnet;

+ (DMManagerAlertHandlingAction)handleButtonWithTypeTapped:(CBAlertButtonType)aButtonType
                                  forLocationAlertWithType:(CBAlertType)anAlertType
                                                atWaypoint:(DMWaypoint *)aWaypoint
                                                fromCarnet:(DMCarnet *)aCarnet;

@end

@interface DMManager (TravelWorkflow)

+ (void)refreshTravellingState;
+ (void)refreshStateForAirport:(DMCheckpoint *)anAirport;
+ (void)refreshStateForCountry:(DMCountry *)aCountry;

@end

@interface DMManager (ServerLogger)

+ (void)logServerAction:(DMLoggedActionType)action withComments:(NSString *)aComments forCarnetGUID:(NSString *)guid;
+ (void)logServerAction:(DMLoggedActionType)action withComments:(NSString *)aComments forCarnet:(DMCarnet *)carnet;
+ (void)logServerAction:(DMLoggedActionType)action withComments:(NSString *)aComments forCarnetWithGUID:(NSString *)GUID;

- (void)sendFailedLogRequests;

@end

@interface DMManager (Location)

+ (void)switchToBackgroundMode;
+ (void)switchToForegroundMode;
+ (NSString *)countryISO;

@end

@interface DMManager (FakeLocation)

+ (id<CBLocation>)fakeLocation;

+ (void)enableFakeLocation:(id<CBLocation>)locationItem;        // should be instance of DMCountry or DMCheckpoint
+ (void)disableFakeLocation;

@end

@interface DMManager (Settings)

+ (BOOL)connectionAvailable;

@end

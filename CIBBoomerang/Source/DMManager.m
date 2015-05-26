//
//  DMManager.m
//  PwC
//
//  Created by Roman on 2/26/13.
//  Copyright (c) 2013 Roman. All rights reserved.
//

#import "DMManager.h"

#import <objc/runtime.h>

#import "CBAlertsManager.h"
#import "CBGateway.h"
#import "CBDateConvertionUtils.h"
#import "CBLocation.h"
#import "CBLocationManager.h"
#import "CBNotificationsManager.h"
#import "CBRequestStorage.h"
#import "NSDate+CLRTicks.h"
#import "DMCountry+Auxilliary.h"
#import "DMCheckpoint.h"

#pragma mark -
#pragma mark - CBLoadCarnetOperation

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface CBLoadCarnetOperation : NSOperation

- (id)initWithCarnetGUID:(NSString *)guid;

@end

@interface CBLoadCarnetOperation ()

@property (nonatomic, copy) NSString *guid;
@property (nonatomic, assign) BOOL customExecuting;
@property (nonatomic, assign) BOOL customFinished;

@end

@implementation CBLoadCarnetOperation

- (id)initWithCarnetGUID:(NSString *)guid
{
    self = [super init];
    
    if (self) {
        self.guid = guid;
    }
    
    return self;
}

- (void)start
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        self.customFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    
    [DMManager loadCarnetWithGUID:self.guid afterScan:NO completionHandler:^(DMCarnet *carnet, NSError *error) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        
        self.customExecuting = NO;
        self.customFinished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }];
    
    self.customExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting {
    return self.customExecuting;
}

- (BOOL)isFinished {
    return self.customFinished;
}

- (BOOL)isConcurrent
{
    return YES;
}

@end

#pragma mark -
#pragma mark - DMManager

/* user defaults */
NSString *const keyUserDefaultsTravelDate       = @"keyUserDefaultsTravelDate";
NSString *const keyUserDefaultsTravelFrom       = @"keyUserDefaultsTravelFrom";
NSString *const keyUserDefaultsFirstAppLaunch   = @"keyUserDefaultsFirstAppLaunch";

/* notifications */
NSString *const DMNotificationTypeAirportInsctructionsReceived  = @"DMNotificationTypeAirportInsctructionsReceived";
NSString *const DMNotificationTypeLocationServicesDisabled      = @"DMNotificationTypeLocationServicesDisabled";
NSString *const DMNotificationTypeLocationError                 = @"DMNotificationTypeLocationError";
NSString *const DMNotificationTypeTravellingStateRefreshed      = @"DMNotificationTypeTravellingStateRefreshed";
NSString *const DMNotificationTypeWillYouBeTravellingSoon       = @"DMNotificationTypeWillYouBeTravellingSoon";

NSString *const keyDMNotificationHeader         = @"keyNotificationHeader";
NSString *const keyDMNotificationInstructions   = @"keyInstructions";
NSString *const keyDMNotificationText           = @"keyNotificationText";

/* Country*/
NSString *const DMManagerModelNameValue         = @"CIBBoomerang";
NSString *const DMManagerCountryPlistName       = @"countries";
NSString *const keyJSONCountryCode              = @"CountryCode ";
NSString *const keyJSONCountryId                = @"CountryId";
NSString *const keyJSONCountryName              = @"CountryName";
NSString *const keyJSONCountrySupportsCarnet    = @"CarnetCountry";

/* airports */
NSString *const DMManagerAirportJsonFileName    = @"Airports";
NSString *const keyDMAirportsAirportName        = @"Airport_Name";
NSString *const keyDMAirportsConfigAirport      = @"keyConfigAirport";
NSString *const keyDMAirportsCountryId          = @"CountryId";
NSString *const keyDMAirportsIATACode           = @"IATACode";
NSString *const keyDMAirportsICAOCode           = @"ICAOcode";
NSString *const keyDMAirportsLatitude           = @"LatitudeDec";
NSString *const keyDMAirportsLocation           = @"Location";
NSString *const keyDMAirportsLongitude          = @"LongitudeDec";

/* locations */
NSString *const keyLocations = @"Locations";
NSString *const keyLocationsAltitude = @"Altitude";
NSString *const keyLocationsId = @"Id";
NSString *const keyLocationsLatitude = @"Latitude";
NSString *const keyLocationsLocation = @"Location";
NSString *const keyLocationsLongitude = @"Longitude";
NSString *const keyLocationsName = @"Name";
NSString *const keyLocationsType = @"Type";
NSString *const keyLocationsCountry = @"Country";


@interface DMManager () <CBLocationManagerDataSource, CBLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray *reconstituteArray;
@property (strong, nonatomic) NSMutableArray *splittingArray;

/* location manager */
@property (strong, nonatomic) CBLocationManager *locationManager;

/* temporary */
@property (strong, nonatomic) DMCheckpoint *fromAirport;
@property (strong, nonatomic) NSDate *travelDate;

@end


@implementation DMManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static DMManager *manager;
#pragma mark - Initialization
+ (DMManager *)sharedManager
{
    if (manager != nil) {
        return manager;
    }
    
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        manager = [[DMManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.reconstituteArray  = [[NSMutableArray alloc] init];
        self.splittingArray     = [[NSMutableArray alloc] init];
		
		self.locationManager = [[CBLocationManager alloc] init];
        
		self.locationManager.delegate   = self;
		self.locationManager.dataSource = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleReminderNotification:)
                                                     name:CBNotificationsManagerHandleReminderNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTravelDayNotification:)
                                                     name:CBNotificationsManagerHandleTravelDayNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged)
                                                     name:CBReachabilityObserverNetworkStatusDidChange
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark    Notification Handling

- (void)handleReminderNotification:(NSNotification *)aNotification
{
    NSString *carnetID = aNotification.userInfo[keyCBCarnetNotificationCarnetId];
    if (!carnetID.length)
        return;
    
    DDLogVerbose(@"%@",carnetID);
}

- (void)handleTravelDayNotification:(NSNotification *)aNotification
{
    NSDate *travelDate = aNotification.userInfo[keyCBCarnetNotificationDate];
    if (travelDate) {
        [DMManager refreshTravellingState];
        NSDate *nextDate = [DMCarnet nextTravelDateAfterDate:travelDate];
        [CBNotificationsManager scheduleTravelDayNotificationForDate:nextDate];
    }
}

- (void)reachabilityChanged
{
    if ([DMManager connectionAvailable]){
        [self sendFailedLogRequests];
        if (![DMCheckpoint count]) {
            [DMManager loadLocations];
        }
    }
}

#pragma mark -
#pragma mark    Store Path

+ (NSManagedObjectContext *)managedObjectContext
{
    return [[DMManager sharedManager] managedObjectContext];
}

+ (void)saveContext
{
    [[DMManager sharedManager] saveContext];
}

- (NSURL *)storeURL
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [url URLByAppendingPathComponent:[DMManagerModelNameValue stringByAppendingString:@".sqlite"]];
}

- (NSString *)storePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [basePath stringByAppendingPathComponent:[DMManagerModelNameValue stringByAppendingPathExtension:@"sqlite"]];
}

#pragma mark -
#pragma mark    Core Data stack
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DMManagerModelNameValue withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self storePath]]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:DMManagerModelNameValue
                                                                     ofType:@"sqlite"];
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:[self storePath] error:NULL];
        }
    }
    
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @YES,NSMigratePersistentStoresAutomaticallyOption,
                             @YES,NSInferMappingModelAutomaticallyOption, nil];
    
    NSURL *storeURL = [self storeURL];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            [[NSFileManager defaultManager] removeItemAtURL:[self storeURL] error:nil];
            DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Utility Functions

+ (void)preloadCountries
{
    if ([DMCountry count]) {
        return;
    }
    
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:DMManagerCountryPlistName
                                                     ofType:@"json"];
    NSArray *countries = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                         options:kNilOptions
                                                           error:&error];
    
    NSManagedObjectContext *context = [DMManager managedObjectContext];
    
    for (NSDictionary *dic in countries) {
        DMCountry *country = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([DMCountry class])
                                                           inManagedObjectContext:context];
        
        country.identifier      = dic[keyJSONCountryId];
        country.code            = [dic[keyJSONCountryCode]  integerValue];
        country.name            = dic[keyJSONCountryName];
        country.supportsCarnet  = [dic [keyJSONCountrySupportsCarnet] boolValue];
    }
    [self saveContext];
}

static BOOL loadCheckpoints = NO;

+ (void)loadLocations
{
    if (loadCheckpoints) {
        return;
    }
    loadCheckpoints = YES;
    //TODO may be removed in future if need update locations
    if ([DMCheckpoint count]) {
        //return;
    }
    [CBGateway sendGETRequestForLocationsWithCompletionBlock:^(NSDictionary *obj){
        NSManagedObjectContext *mainContext = [DMManager managedObjectContext];

        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        context.parentContext = mainContext;
        
        [context performBlock:^(){
            for (NSDictionary *location in obj[keyLocations]) {
                DMCheckpoint *checkpoint = [DMCheckpoint insertOrRaplaceCheckpointWithId:location[keyLocationsId]
                                                                  inManagedObjectContext:context];
                checkpoint.altitude = location[keyLocationsAltitude];
                checkpoint.latitude = location[keyLocationsLatitude];
                checkpoint.location = location[keyLocationsLocation];
                checkpoint.longitude = location[keyLocationsLongitude];
                checkpoint.name = location[keyLocationsName];
                checkpoint.type = location[keyLocationsType];
                checkpoint.country = [DMCountry countryByIdentifier:location[keyLocationsCountry]
                                                          inContext:context];
            }
            __block NSError *error = nil;
            if ([context save:&error]) {
                //TODO show error
                [mainContext performBlockAndWait:^(){
                    [mainContext save:&error];
                }];
            }
            loadCheckpoints = NO;
            NSLog(@"Loaded locations");
        }];
    }
                                                  errorBlock:^(NSError *error){
                                                      loadCheckpoints = NO;
                                                      //TODO show error that user need to get data
                                                  }];
}

+ (void)cleanDublicates
{
    [DMCheckpoint cleanDublicates];
}

#pragma mark - CBLocationManager

+ (void)switchToBackgroundMode
{
	[manager.locationManager switchLocationManagerToBackgroundMode];
    
    if ([self fakeLocation]) {
        [self enableFakeLocation:[self fakeLocation]];
    }
}

+ (void)switchToForegroundMode
{
	[manager.locationManager switchLocationManagerInForegroundMode];
    
    [DMManager refreshCarnetsStatuses];
    [DMManager refreshTravellingState];
    
    if ([DMManager connectionAvailable]) {
        [CBAlertsManager updateAlertsPlist];
    }
    
    if ([self fakeLocation]) {
        [self enableFakeLocation:[self fakeLocation]];
    }
}

+ (id<CBLocation>)currentLocation
{
    if ([self fakeLocation]) {
        return [self fakeLocation];
    } else {
        return manager.locationManager.currentLocation;
    }
}

+ (NSString *)countryISO
{
    if (self.currentLocation.ISOCodeSpecified)
        return self.currentLocation.countryISO;
    
    return nil;
}

+ (DMCheckpoint *)fromAirport
{
    return manager.fromAirport;
}

#pragma mark - CBLocationManagerDataSource

- (void)locationManager:(CBLocationManager *)manager regionsForGeopointWithLongitude:(CLLocationDegrees)longitude
               latitude:(CLLocationDegrees)latitude
      completionHandler:(void (^)(NSArray *))completionHandler
{
	[DMCheckpoint retrieveNearestCheckpointsForLocationWithLatitude:latitude
                                                          longitude:longitude
                                                  completionHandler:completionHandler];
}

#pragma mark - CBLocationManagerDelegate

- (void)locationManager:(CBLocationManager *)manager willStartDetectingAirportWithID:(NSString *)locationId
{
    DDLogVerbose(@"%s %@",__PRETTY_FUNCTION__, locationId);
    
    DMCheckpoint *fromLocation = [DMCheckpoint checkpointById:locationId];
    self.fromAirport = fromLocation;
    
    [DMManager logServerAction:DMLoggedActionTypeAirportDetected
                  withComments:[NSString stringWithFormat:@"Did detect location with ID %@", fromLocation.ident]
             forCarnetWithGUID:nil];
    
    [DMManager refreshTravellingState];
}

- (void)locationManager:(CBLocationManager *)manager didDetectCountryWithISOCode:(NSString *)anISOCode
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [DMManager updateLocalCarnetsForCurrentCountry];
        [DMManager refreshTravellingState];
    }
    else {
        [CBNotificationsManager presentCountryChangeNotification:anISOCode];
    }
}

- (void)locationManager:(CBLocationManager *)manager didDetectAirportWithID:(NSString *)locationId
{
	DMCheckpoint *fromLocation = [DMCheckpoint checkpointById:locationId];
    if (![self.fromAirport isEqual:fromLocation]) {
        [DMManager logServerAction:DMLoggedActionTypeAirportDetected
                      withComments:[NSString stringWithFormat:@"Did detect airport with Id %@", fromLocation.ident]
                 forCarnetWithGUID:nil];
        
        [DMManager refreshTravellingState];
    }
}

- (void)locationManager:(CBLocationManager *)manager didFailWithError:(NSError *)error authorizationError:(BOOL)authorization
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	if (authorization) {
		NSString *text      = NSLocalizedString(@"LOCATION_SERVICES_DISABLED_MESSAGE", @"Location services disabled message and instuctions how to turn it on.");
		NSString *header    = NSLocalizedString(@"LOCATION_SERVICES_DISABLED_HEADER", @"Location services disabled alert's header");
		[center postNotificationName:DMNotificationTypeLocationServicesDisabled
							  object:nil
							userInfo:@{keyDMNotificationText : text, keyDMNotificationHeader : header}];
	}
	else {
		NSString *header = @"Location Services Error";
		[center postNotificationName:DMNotificationTypeLocationError
							  object:nil
							userInfo:@{keyDMNotificationText : error.localizedDescription, keyDMNotificationHeader : header}];
	}
}

@end

@class CBLoadCarnetOperation;

@implementation DMManager (Carnets)

+ (void)updateLocalCarnetsForCurrentCountry
{
    if ([self currentLocation] && [[self currentLocation] ISOCodeSpecified]) {
        DMCountry *country = [DMCountry countryByIdentifier:[self currentLocation].countryISO];
        
        if (country) {
            NSArray *carnets  = [DMCarnet obtainAllCarnets];
            
            for (DMCarnet *carnet in carnets) {
                [carnet refreshRouteWithCountry:country afterScan:NO];
                [self updateServerForCarnet:carnet];
            }
            
            [self saveContext];
            [self postRefreshNotification];
        }
    }
}

+ (void)addWaypointForCarnet:(DMCarnet *)aCarnet
       withCountryIdentifier:(NSString *)aCountryIdentifier
               departureDate:(NSDate *)aDepartureDate 
                        kind:(DMWaypointKind)aKind
                      status:(DMWaypointStatus)aStatus
{
    [self scheduleTravelDayNotification:aDepartureDate];
    
    DMWaypoint *waypoint = [DMWaypoint obtainWaypointObjectWithCountryID:aCountryIdentifier
                                                             arrivalDate:aDepartureDate
                                                            depatureDate:nil
                                                                    kind:aKind
                                                                  status:aStatus];
    [aCarnet addWaypointsObject:waypoint];
    [manager saveContext];
}

+ (DMWaypoint *)insertWaypointForCarnet:(DMCarnet *)aCarnet
                            withISOCode:(NSString *)anISOCode
                            arrivalDate:(NSDate *)anArrivalDate
                                   kind:(DMWaypointKind)aKind
                                 status:(DMWaypointStatus)aStatus
{
    DMWaypoint *waypoint = [DMWaypoint obtainWaypointObjectWithCountryID:anISOCode
                                                             arrivalDate:anArrivalDate
                                                            depatureDate:nil
                                                                    kind:aKind
                                                                  status:aStatus];
    [aCarnet addWaypointsObject:waypoint];
    [manager saveContext];

    return waypoint;
}

+ (void)setCarnet:(DMCarnet *)carnet active:(BOOL)active
{
    [carnet setCarnetActive:YES];
    [self saveContext];
}

+ (void)verifyCarnet:(DMCarnet *)carnet
{
    [carnet setCarnetVerified:YES];
    [self saveContext];
    [DMManager logServerAction:DMLoggedActionTypeAdd
                  withComments:[NSString stringWithFormat:@"Verified carnet with ID %@", carnet.identifier]
                     forCarnet:carnet];
}

+ (void)rejectCarnet:(DMCarnet *)aCarnet
{
    [DMManager logServerAction:DMLoggedActionTypeReject
                  withComments:[NSString stringWithFormat:@"Rejected carnet with ID %@", aCarnet.identifier]
                     forCarnet:aCarnet];
    
    [CBGateway sendDELETERequestForCarnetWithGUID:aCarnet.guid completionBlock:nil errorBlock:nil];
    [CBNotificationsManager cancelNotificationsForCarnetWithID:aCarnet.guid];
    
    [[self managedObjectContext] deleteObject:aCarnet];
    [self saveContext];
}

+ (void)removeCarnet:(DMCarnet *)aCarnet
{    
    [DMManager logServerAction:DMLoggedActionTypeDelete
                  withComments:[NSString stringWithFormat:@"Carnet deleted from device with id %@",[CBServerLoggingUtils deviceId]]
                     forCarnet:aCarnet];
    
    [CBGateway sendDELETERequestForCarnetWithGUID:aCarnet.guid completionBlock:nil errorBlock:nil];
    [CBNotificationsManager cancelNotificationsForCarnetWithID:aCarnet.guid];
    
    [[self managedObjectContext] deleteObject:aCarnet];
    [self saveContext];
}

+ (void)removeWaypoint:(DMWaypoint *)aWaypoint
{
    DMCarnet *carnetObject = aWaypoint.carnet;
    [carnetObject removeWaypoint:aWaypoint];
  
    [DMManager logServerAction:DMLoggedActionTypeTravelPlanDelete
                  withComments:[NSString stringWithFormat:@"Delete waypoint with Country ISO code - %@", aWaypoint.country.identifier]
                     forCarnet:carnetObject];

    [DMManager updateCarnetWithGUID:carnetObject.guid
                         parameters:[carnetObject patchParametersWithSplittingData:nil]
                  completionHandler:^(NSString *timeStamp, NSError *error) {
                      if (timeStamp) {
                          carnetObject.timestamp = timeStamp;
                      }
                      if ([[self managedObjectContext] hasChanges])
                          [self saveContext];
                  }];
}

+ (void)carnetQRScannedWithGUID:(NSString *)aGUID
{
    [DMManager logServerAction:DMLoggedActionTypeScan
                  withComments:[NSString stringWithFormat:@"Scanned carnet with GUID - %@", aGUID]
             forCarnetWithGUID:aGUID];
}

+ (void)refreshCarnetsStatuses
{
    NSArray *carnets = [DMCarnet obtainAllCarnets];
    [carnets makeObjectsPerformSelector:@selector(refreshCarnetStatus)];
}

@end

@implementation DMManager (Gateway)

+ (void)loadCarnetWithGUID:(NSString *)GUID
         completionHandler:(DMManagerCarnetDownloadCompletionHandler)completionHandler
{
    [self loadCarnetWithGUID:GUID
                   afterScan:NO
           completionHandler:completionHandler];
}

+ (void)loadCarnetWithGUID:(NSString *)GUID
                 afterScan:(BOOL)afterScan
         completionHandler:(DMManagerCarnetDownloadCompletionHandler)completionHandler
{
    [CBGateway sendGETRequestForCarnetWithGUID:GUID completionBlock:^(NSDictionary *data) {
        
        NSString *trackedByDeviceId = data[keyDMCarnetDeviceId];
        
        if (!trackedByDeviceId || [trackedByDeviceId isKindOfClass:[NSNull class]] || [trackedByDeviceId isEqualToString:[CBServerLoggingUtils deviceId]]) {
            DMCarnet *carnet = [DMCarnet obtainCarnetWithData:data afterScan:afterScan];
            [self updateServerForCarnet:carnet];
            [self sendFailedRequestsForCarnet:carnet];
             
            if ([[self managedObjectContext] hasChanges])
                [self saveContext];
             
            if (completionHandler) {
                 completionHandler (carnet, nil);
            }
        } else {
            if (completionHandler) {
                NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : @"This Carnet is being tracked on another device" };
                NSError *trackedError   = [[NSError alloc] initWithDomain:CONNECTION_MANAGER_DOMAIN
                                                                     code:CBConnectionManagerResponseStatusAlreadyTracked
                                                                 userInfo:errorDict];
                completionHandler(nil, trackedError);
            }
        }
     } errorBlock:^(NSError *error) {
         if (completionHandler) {
             completionHandler (nil, error);
         }
     }];
}

+ (void)updateCarnetWithGUID:(NSString *)GUID
                  parameters:(NSDictionary *)params
           completionHandler:(DMManagerUpdateCompletionHandler)completionHandler
{
    [CBGateway sendUPDATERequestForCarnetWithGUID:GUID
                                  updateParametrs:params
                                  completionBlock:^(NSString *timestamp) {
                                      if (completionHandler)
                                          completionHandler (timestamp, nil);
                                  }
                                       errorBlock:^(NSError *error) {
                                           if (completionHandler) {
                                               completionHandler (nil, error);
                                           }
                                       }];
}

+ (void)loadAlertForAirportWithID:(NSString *)anID
                completionHandler:(DMManagerLoadAlertsCompletionHandler)completionHandler
{
    [CBGateway sendGETRequestForAirportInstructionsWithAirportID:anID
                                                 completionBlock:^(NSDictionary *dic) {
                                                     completionHandler (dic, NO);
                                                 } errorHandler:^(NSError *error) {
                                                     BOOL retBool = (error != nil) ? YES : NO;
                                                     completionHandler (nil, retBool);
                                                 }];
}

+ (void)loadAlertForCountryWithISOCode:(NSString *)anISOCode
                     completionHandler:(DMManagerLoadAlertsCompletionHandler)completionHandler
{
    [CBGateway sendGETRequestForCountryInstructionsWithCountryISOCode:anISOCode
                                                      completionBlock:^(NSDictionary *dic) {
                                                          completionHandler (dic, NO);
                                                      } errorHandler:^(NSError *error) {
                                                          completionHandler (nil , YES);
                                                      }];
}

+ (void)loadAlertsWithCompletionHandler:(DMManagerLoadAlertsCompletionHandler)completionHandler
{
    [CBGateway sendGETRequestForAlertsWithParametrs:nil
                                    completionBlock:^(NSDictionary *alerts) {
                                        completionHandler (alerts, NO);
                                    } errorBlock:^(NSError *error) {
                                        completionHandler (nil, YES);
                                    }];
}


+ (void)updateServerForCarnet:(DMCarnet *)aCarnet
{
    [self updateCarnetWithGUID:aCarnet.guid
                    parameters:[aCarnet patchParametersWithSplittingData:nil]
             completionHandler:^(NSString *timeStamp, NSError *error) {
                 if (timeStamp) {
                     aCarnet.timestamp = timeStamp;
                 }
                 if ([[manager managedObjectContext] hasChanges])
                     [manager saveContext];
             }];
}

+ (void)sendFailedRequestsForCarnet:(DMCarnet *)aCarnet
{
    NSArray *failedRequests = [CBRequestStorage fetchAndDeleteRequestsParametersForPath:CBRequestStoragePath_Carnet
                                                                             method:GATEWAY_REQUEST_METHOD_PATCH
                                                                         carnetGUID:aCarnet.guid];
    
    for (NSDictionary *params in failedRequests) {
        NSMutableDictionary *timestampedParams = [NSMutableDictionary dictionaryWithDictionary:params];
        [timestampedParams setObject:aCarnet.timestamp forKey:keyDMCarnetTimestamp];
        
        [self updateCarnetWithGUID:aCarnet.guid
                             parameters:timestampedParams
                      completionHandler:^(NSString *timeStamp, NSError *error) {
                          if (timeStamp) {
                              aCarnet.timestamp = timeStamp;
                          }
                          
                          if ([[self managedObjectContext] hasChanges]) {
                              [self saveContext];
                          }
                      }];
    }
}

@end

@implementation DMManager (SplitManaging)

NSString *const keyCBGatewaySplittingKey = @"Key";
NSString *const keyCBGatewaySplittingValue = @"Value";
NSString *const CBGatewayReconstituteEmptuConutryIdentifier = @"";

+ (void)splitCarnets:(DMCarnet *)carnet
                item:(DMItem *)item
          atWaypoint:(DMWaypoint *)waypoint
   completionHandler:(CBSimpleCompletionBlock)completionHandler
{
    item.waypoint = waypoint;
    item.splitted = YES;
    
	__block NSDictionary *dicToRemove;
	NSUInteger ident = item.globalIdentifier ? item.globalIdentifier : item.identifier;
	[manager.reconstituteArray enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
        if ([[dictionary objectForKey:keyCBGatewaySplittingKey] isEqualToNumber:@(ident)]) {
            dicToRemove = dictionary;
			*stop = YES;
		}
	}];
    
	if (dicToRemove) {
		[manager.reconstituteArray removeObject:dicToRemove];
		completionHandler ((manager.reconstituteArray.count == 0) && (manager.splittingArray.count == 0));
		return;
	}
	
    [manager.splittingArray addObject:@{keyCBGatewaySplittingKey    : @(ident),
                                        keyCBGatewaySplittingValue  : item.waypoint.country.identifier}];
	completionHandler (NO);
}

+ (void)reconstituteCarnets:(DMCarnet *)carnet
                       item:(DMItem *)item
                 atWaypoint:(DMWaypoint *)waypoint
		  completionHandler:(CBSimpleCompletionBlock)completionHandler
{
    item.waypoint = waypoint;
    item.splitted = NO;
	__block NSDictionary *dicToRemove;
	
    NSUInteger ident = item.globalIdentifier ? item.globalIdentifier : item.identifier;
	[manager.splittingArray enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
		if ([[dictionary objectForKey:keyCBGatewaySplittingKey] isEqualToNumber:@(ident)]) {
			dicToRemove = dictionary;
			*stop = YES;
		}
	}];
	
	if (dicToRemove) {
		[manager.splittingArray removeObject:dicToRemove];
		completionHandler ((manager.reconstituteArray.count == 0) && (manager.splittingArray.count == 0));
		return;
	}
    [manager.reconstituteArray addObject:@{ keyCBGatewaySplittingKey    :   @(ident),
                                            keyCBGatewaySplittingValue  :   CBGatewayReconstituteEmptuConutryIdentifier}];
	completionHandler (NO);
}

+ (void)reconstituteCarnets:(DMCarnet *)carnet
                      items:(NSArray *)items
                 atWaypoint:(DMWaypoint *)waypoint
		  completionHandler:(CBSimpleCompletionBlock)completionHandler
{
    for (DMItem *itemObj in items) {
        if ((itemObj.waypoint != waypoint)&& (itemObj.waypoint.country == waypoint.country)){
            itemObj.waypoint = waypoint;
            itemObj.splitted = NO;
        }
    }
    [DMManager acceptAllSplittingChangesForCarnet:carnet completionHandler:completionHandler];
}

+ (void)acceptAllSplittingChangesForCarnet:(DMCarnet *)carnet completionHandler:(CBSimpleCompletionBlock)completionHandler
{
    [self saveContext];
    
    NSArray *finalArray = [manager.splittingArray arrayByAddingObjectsFromArray:manager.reconstituteArray];
    NSMutableArray *itemsParam = [NSMutableArray array];
    
    for (NSDictionary *item in finalArray) {
        [itemsParam addObject:@{[NSString stringWithFormat:@"%@", item[keyCBGatewaySplittingKey]]: item[keyCBGatewaySplittingValue]}];
    }
    
    [self updateCarnetWithGUID:carnet.guid
                    parameters:[carnet patchParametersWithSplittingData:itemsParam]
             completionHandler:^(NSString *timeStamp, NSError *error) {
                 if (timeStamp)
                     carnet.timestamp = timeStamp;
                 if ([[self managedObjectContext] hasChanges])
                     [self saveContext];
             }];
    
    [carnet refreshCarnetStatus];
    
    int splitCount          = [manager.splittingArray count];
    int reconstituteCount   = [manager.reconstituteArray count];
    
    if (splitCount)
        [DMManager logServerAction:DMLoggedActionTypeSplit
                      withComments:[NSString stringWithFormat:@"User decided to split %d items carnet with ID - %@",splitCount, carnet.identifier]
                         forCarnet:carnet];
    
    if (reconstituteCount)
        [DMManager logServerAction:DMLoggedActionTypeReconstitute
                      withComments:[NSString stringWithFormat:@"User decided to split %d items carnet with ID - %@",reconstituteCount, carnet.identifier]
                         forCarnet:carnet];
    
    [manager.splittingArray removeAllObjects];
    [manager.reconstituteArray removeAllObjects];
    
    if (completionHandler)
        completionHandler (YES);
}

+ (void)rollbackAllSplittingChangesForCarnet:(DMCarnet *)carnet completionHandler:(CBSimpleCompletionBlock)completionHandler
{
    
    [[self managedObjectContext] rollback];
    
    int splitCount          = [manager.splittingArray count];
    int reconstituteCount   = [manager.reconstituteArray count];
    
    if (splitCount)
        [DMManager logServerAction:DMLoggedActionTypeSplitCancel
                      withComments:[NSString stringWithFormat:@"User decided to cancel spliting of %d items carnet with ID - %@",splitCount, carnet.identifier]
                         forCarnet:carnet];
    
    if (reconstituteCount)
        [DMManager logServerAction:DMLoggedActionTypeReconstituteCancel
                      withComments:[NSString stringWithFormat:@"User decided to cancel reconstitution of %d items carnet with ID - %@", reconstituteCount, carnet.identifier]
                         forCarnet:carnet];
    
    [manager.splittingArray removeAllObjects];
    [manager.reconstituteArray removeAllObjects];
    
    if (completionHandler)
        completionHandler (YES);
}

@end

@implementation DMManager (Notifications)

+ (void)scheduleReminderNotificationForCarnet:(DMCarnet *)carnet afterDaysPassed:(int)daysCount
{
    NSDate *date = [CBDateConvertionUtils addDays:daysCount toDate:[NSDate date]];
    [CBNotificationsManager scheduleReminderNotificationForCarnetWithGUID:carnet.guid carnetId:carnet.identifier fireDate:date];
}

+ (void)scheduleTravelDayNotification:(NSDate *)travelDay
{
    NSDate *scheduledDate = [CBNotificationsManager scheduledTravelDate];
    if ([scheduledDate compare:travelDay] == NSOrderedDescending) {
        [CBNotificationsManager cancelTravelDateNotifications:scheduledDate];
        [CBNotificationsManager scheduleTravelDayNotificationForDate:travelDay];
    }
}

+ (void)travelDayDetected:(NSDate *)travelDay
{
	if ([manager.travelDate compare:travelDay] != NSOrderedSame) {
		manager.travelDate                      = travelDay;
        [[NSNotificationCenter defaultCenter] postNotificationName:DMNotificationTypeWillYouBeTravellingSoon object:nil];
	}
}

+ (void)postRefreshNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DMNotificationTypeTravellingStateRefreshed object:nil];
}

@end

@implementation DMManager (ServerLogger)

+ (void)logServerAction:(DMLoggedActionType)action withComments:(NSString *)aComments forCarnetGUID:(NSString *)guid
{
    [manager logAction:action forCarnetWithGuid:guid location:[self currentLocation] comments:aComments];
}

+ (void)logServerAction:(DMLoggedActionType)action withComments:(NSString *)aComments forCarnet:(DMCarnet *)carnet;
{
    [manager logAction:action forCarnetWithGuid:carnet.guid location:[self currentLocation] comments:aComments];
}

+ (void)logServerAction:(DMLoggedActionType)action withComments:(NSString *)aComments forCarnetWithGUID:(NSString *)GUID;
{
    [manager logAction:action forCarnetWithGuid:GUID location:[self currentLocation] comments:aComments];
}

- (void)logAction:(DMLoggedActionType)action forCarnetWithGuid:(NSString *)GUID location:(id<CBLocation>)location comments:(NSString *)aComments
{
    NSDictionary *logParams = @{
                             keyActionCountryId :   (location) ? location.countryISO : @"  ",
                             keyActionLatitude  :   (location) ? @(location.clLocation.coordinate.latitude)   : @(0.),
                             keyActionLongitude :   (location) ? @(location.clLocation.coordinate.longitude)  : @(0.),
                             keyActionDeviceId  :   [CBServerLoggingUtils deviceId],
                             keyActionDate      :   [CBDateConvertionUtils dateStringFromCarnetTimeInterval:[[NSDate date] timeIntervalSinceReferenceDate]],
                             keyActionName      :   [CBServerLoggingUtils actionNameForIndex:action],
                             keyActionTimezone  :   @([CBServerLoggingUtils timezoneOffset]),
                             keyActionVersion   :   [self applicationVersion]
                             };
    
    NSMutableDictionary *mutableLogParams = [NSMutableDictionary dictionaryWithDictionary:logParams];

    if (aComments) {
        [mutableLogParams setObject:aComments forKey:keyActionData];
    }
    
    if (GUID) {
        [mutableLogParams setObject:GUID forKey:keyActionGUID];
    }
    
    NSDictionary *finalParams = @{keyActionLogs : @[mutableLogParams]};
    [CBGateway sendLOGRequestForCarnetWithGUID:GUID
                               loggingParamets:finalParams
                               completionBlock:^(id obj) {
                                   // do nothing
                               } errorBlock:^(NSError *error) {
                                   [CBRequestStorage saveLogRequestWithParametrs:finalParams forCarnetWithGUID:GUID];
                               }];
}

- (void)sendFailedLogRequests
{
    NSArray *failedRequests = [CBRequestStorage fetchAndDeleteLogRequests];
    for (NSDictionary *parametrs in failedRequests) {
        [parametrs enumerateKeysAndObjectsUsingBlock:^(NSString *aGUID, NSDictionary *aParams, BOOL *stop) {
            [CBGateway sendLOGRequestForCarnetWithGUID:aGUID
                                       loggingParamets:aParams
                                       completionBlock:nil
                                            errorBlock:^(NSError *error) {
                                                [CBRequestStorage saveLogRequestWithParametrs:aParams forCarnetWithGUID:aGUID];
                                            }];
        }];
    }
}

- (NSString*)applicationVersion
{
    NSString *deviceVersion = [[UIDevice currentDevice] platformString];
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"iOS|%@|%@|%@", deviceVersion, iosVersion, buildVersion];
}

@end

@implementation DMManager (Alerts)

+ (DMManagerAlertHandlingAction)handlingActionForSimpleAlertWithType:(CBAlertType)anAlertType
                                                       buttonPressed:(CBAlertButtonType)aButtonType
                                                           forCarnet:(DMCarnet *)aCarnet
{
    DMManagerAlertHandlingAction retAction = [aCarnet handleButtonWithTypeTapped:aButtonType forSimpleAlertWithType:anAlertType];
    [self saveContext];
    return retAction;
}

+ (DMManagerAlertHandlingAction)handleButtonWithTypeTapped:(CBAlertButtonType)aButtonType
                                  forLocationAlertWithType:(CBAlertType)anAlertType
                                                atWaypoint:(DMWaypoint *)aWaypoint
                                                fromCarnet:(DMCarnet *)aCarnet
{
    DMManagerAlertHandlingAction retAction = [aCarnet handleButtonWithTypeTapped:aButtonType forLocationAlertWithType:anAlertType atWaypoint:aWaypoint];
    [self saveContext];
    return retAction;
}

@end

@implementation DMManager (TravelWorkflow)

+ (BOOL)isAlreadyStartedTravelFromCountry:(NSString *)aCountryISO atDate:(NSDate *)aDate
{
    NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
    NSDate *defaultsDate        = [defaults objectForKey:keyUserDefaultsTravelDate];
    if (!defaultsDate)
        return NO;
    
    NSString *defaultsISO   = [defaults objectForKey:keyUserDefaultsTravelFrom];
    if (!defaultsISO)
        return NO;
    
    BOOL isDateCorrect      = (![CBDateConvertionUtils isDayPassedFromDate:aDate toDate:defaultsDate]);
    return (isDateCorrect && [defaultsISO isEqualToString:aCountryISO]);
}

+ (void)setTravelStartedFromCountry:(NSString *)aCountryISO atDate:(NSDate *)aDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:aCountryISO forKey:keyUserDefaultsTravelFrom];
    [defaults setObject:aDate forKey:keyUserDefaultsTravelDate];
    [defaults synchronize];
}

+ (void)refreshTravellingState
{
    NSDate *today = [[NSDate date] midnightUTC];
    
    if (![DMCarnet isTravelScheduledForDate:today]) {
        /* no travels scheduled */
        return;
    }
    else {
        NSArray *allCarnets = [DMCarnet obtainActiveCarnets];
        [allCarnets makeObjectsPerformSelector:@selector(refreshTravelStateForDate:) withObject:today];
    }
    
    if (![self currentLocation].ISOCodeSpecified)
        return;
    
    if ([self isAlreadyStartedTravelFromCountry:[self currentLocation].countryISO atDate:today])
        return;

    if ([DMManager fromAirport])  {
        [self refreshStateForAirport:[DMManager fromAirport]];
    }
    else {
        DMCountry *aCountry = [DMCountry countryByIdentifier:[self currentLocation].countryISO];
        [self refreshStateForCountry:aCountry];
    }
}

+ (void)refreshStateForAirport:(DMCheckpoint *)anCheckpoint
{
    NSArray *carnetArray = [DMCarnet obtainAllCarnets];
    [carnetArray makeObjectsPerformSelector:@selector(refreshStateForAirport:) withObject:anCheckpoint];
    
    [self saveContext];
    [self postRefreshNotification];
}

+ (void)refreshStateForCountry:(DMCountry *)aCountry
{
    NSAssert(aCountry != nil, @"Country cannot be nil");
    
    NSArray *activeCarnets  = [DMCarnet obtainActiveCarnets];
    [activeCarnets makeObjectsPerformSelector:@selector(refreshStateWithCountry:) withObject:aCountry];
    
    [self saveContext];
    [self postRefreshNotification];
}

@end

@implementation DMManager (Settings)

+ (BOOL)connectionAvailable
{
    if (![CBSettings wifiOnlyOn])
        return [CBReachabilityObserver anyConnectionAvailable];
    
    BOOL isTravelling   = ![[DMManager countryISO] isEqualToString:@"US"];
    if (!isTravelling)
        return [CBReachabilityObserver anyConnectionAvailable];
    
    return ([CBReachabilityObserver wifiConnectionAvailable]);
}

@end

@implementation DMManager (FakeLocation)

#define FAKE_LOCATION_TYPE_KEY      @"fakeLocationType"
#define FAKE_LOCATION_TYPE_COUNTRY  @"country"
#define FAKE_LOCATION_TYPE_AIRPORT  @"airport"

#define FAKE_LOCATION_ITEM_ID_KEY   @"fakeLocationItemId"

static id<CBLocation> fakeLocation = nil;

+ (id<CBLocation>)fakeLocation
{
    if (!fakeLocation) {
        NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:FAKE_LOCATION_TYPE_KEY];
        
        if (type) {
            NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:FAKE_LOCATION_ITEM_ID_KEY];
            
            if (identifier) {
                if ([type isEqualToString:FAKE_LOCATION_TYPE_COUNTRY]) {
                    fakeLocation = [DMCountry countryByIdentifier:identifier];
                } else if ([type isEqualToString:FAKE_LOCATION_TYPE_AIRPORT]) {
                    fakeLocation = [DMCheckpoint checkpointById:identifier];
                }
            }
        }
    }
    
    return fakeLocation;
}

+ (void)enableFakeLocation:(id<CBLocation>)locationItem
{
    if ([(NSObject *)locationItem isKindOfClass:[DMCountry class]]) {
        [self enableFakeLocationWithCountry:(DMCountry *)locationItem];
    } else if ([(NSObject *)locationItem isKindOfClass:[DMCheckpoint class]]) {
        [self enableFakeLocationWithAirport:(DMCheckpoint *)locationItem];
    } else {
        NSAssert(NO, @"Instance %@ cannot be set as fake location", locationItem);
    }
    
    [self updateLocalCarnetsForCurrentCountry];
}

+ (void)enableFakeLocationWithAirport:(DMCheckpoint *)checkpoint
{
    fakeLocation = checkpoint;
    
    [[NSUserDefaults standardUserDefaults] setObject:FAKE_LOCATION_TYPE_AIRPORT forKey:FAKE_LOCATION_TYPE_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[checkpoint ident] forKey:FAKE_LOCATION_ITEM_ID_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [manager.locationManager stopAllActivities];
    
    //Here we need to post notification that we in zone
    [manager locationManager:nil willStartDetectingAirportWithID:checkpoint.ident];
}

+ (void)enableFakeLocationWithCountry:(DMCountry *)country
{
    fakeLocation = country;
    
    [[NSUserDefaults standardUserDefaults] setObject:FAKE_LOCATION_TYPE_COUNTRY forKey:FAKE_LOCATION_TYPE_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[country identifier] forKey:FAKE_LOCATION_ITEM_ID_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [manager.locationManager stopAllActivities];
}

+ (void)disableFakeLocation
{
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:FAKE_LOCATION_TYPE_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:FAKE_LOCATION_ITEM_ID_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    fakeLocation = nil;
    [manager.locationManager resumeAllActivities];
    
    [self updateLocalCarnetsForCurrentCountry];
}

@end

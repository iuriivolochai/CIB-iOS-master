//
//  CBLocationManager.m
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 6/11/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBLocationManager.h"

#import <CoreLocation/CoreLocation.h>

#import "CBDateConvertionUtils.h"
#import "CBLocation.h"
#import "CBRegion.h"

NSString * const keyLocationManagerAirportID =   @"airportID";
NSString * const keyLocationManagerLatitude  =   @"latitude";
NSString * const keyLocationManagerLongitude =   @"longitude";

NSString * const kPrefixLocationRegion        =   @"Carnet_";

static double   kLocationManagerRegionRadius                 = 2000.;
static double   kLocationManagerIvalidCoordinateValue        = 0.;
static int      kLocationManagerActiveModePollingInterval    = 30;

typedef NS_ENUM(int, CBLocationManagerPollingMode) {
	CBLocationManagerPollingModeNone = 0,
	CBLocationManagerPollingModeGetLocation,
	CBLocationManagerPollingModeNormal,
	CBLocationManagerPollingModeDetectingAirport,
	CBLocationManagerPollingModeInAirport
};

@interface CBLocationManager () <CLLocationManagerDelegate>

@property (assign, nonatomic) CBLocationManagerPollingMode  pollingMode;
@property (strong, nonatomic) CBLocation                    *updatedLocation;
@property (strong, readwrite, nonatomic) CBLocation         *currentLocation;
@property (strong, nonatomic) CBRegion                      *activeRegion;

@property (assign, nonatomic) CLAuthorizationStatus         authorizationStatus;
@property (strong, nonatomic) CLLocationManager             *locationManager;

@property (strong, nonatomic) NSMutableArray                *regions;

@property (assign, nonatomic, getter = isNeedToShowAutorizationError) BOOL needToShowAutorizationError;

// for fake location needs
@property (nonatomic, assign) CBLocationManagerPollingMode  prevPollingMode;

@end

@implementation CBLocationManager

- (id)init
{
	self = [super init];
	if (self) {
        _needToShowAutorizationError = YES;
        [self initializeLocationManager];
	}
	return self;
}

#pragma mark - Public

- (void)switchLocationManagerInForegroundMode
{
	if (self.pollingMode != CBLocationManagerPollingModeGetLocation)
		self.pollingMode  = CBLocationManagerPollingModeGetLocation;
}

- (void)switchLocationManagerToBackgroundMode
{
//    if (_authorizationStatus == kCLAuthorizationStatusDenied)
//        _authorizationStatus = kCLAuthorizationStatusNotDetermined;
    if (self.pollingMode != CBLocationManagerPollingModeGetLocation)
		self.pollingMode  = CBLocationManagerPollingModeGetLocation;
}

- (void)stopAllActivities
{
    if (self.prevPollingMode != CBLocationManagerPollingModeNone) {
        return;
    }
    
    [self.locationManager stopUpdatingLocation];
    [self stopAllRegionsFromPolling];
    [self stopPolling];
    
    self.prevPollingMode = self.pollingMode;
    self.pollingMode = CBLocationManagerPollingModeNone;
}

- (void)resumeAllActivities
{
    if (self.prevPollingMode == CBLocationManagerPollingModeNone) {
        return;
    }
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self refreshAutorizationStatus];
    self.pollingMode = self.prevPollingMode;
    self.prevPollingMode = CBLocationManagerPollingModeNone;
}

#pragma mark - Config

- (void)refreshAutorizationStatus
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    self.authorizationStatus = status;
    if (status == kCLAuthorizationStatusDenied) {
        [self stopPolling];
        if (_needToShowAutorizationError) {
            [self.delegate locationManager:self didFailWithError:nil authorizationError:YES];
            _needToShowAutorizationError = NO;
        }
    }
    else {
        _needToShowAutorizationError = YES;
        [self startPolling];
    }
    
}

- (void)initializeLocationManager
{
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLLocationAccuracyKilometer;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    self.authorizationStatus = kCLAuthorizationStatusNotDetermined;
    
    self.regions = [[NSMutableArray alloc] initWithCapacity:6];
}

#pragma mark - Setters && Getters

- (void)setPollingMode:(CBLocationManagerPollingMode)pollingMode
{
	if (_pollingMode != pollingMode) {
        _pollingMode = pollingMode;
        
		switch (pollingMode) {
			case CBLocationManagerPollingModeInAirport: {
				[self.delegate locationManager:self
                        didDetectAirportWithID:[self airportIDFromRegionID:self.activeRegion.region.identifier]];
                
                if ([self isAlreadyPollingRegion:self.activeRegion.region])
                    [self.locationManager startMonitoringForRegion:self.activeRegion.region];
			}
            break;
			case CBLocationManagerPollingModeDetectingAirport: {
				[self.delegate locationManager:self willStartDetectingAirportWithID:[self airportIDFromRegionID:self.activeRegion.region.identifier]];
				[self performSelector:@selector(airportDetected:) withObject:self.activeRegion afterDelay:[self detectingInterval]];
			}
			break;
			case CBLocationManagerPollingModeGetLocation: {
				[self refreshAutorizationStatus];
			}
			break;
			case CBLocationManagerPollingModeNormal: {
				[self startRegionPollingForRegions:self.regions];
			}
			break;
			default:
				break;

		}
	}
}

- (void)geocodeLocation:(CLLocation *)location completionHandler:(void (^)(BOOL error,NSString *countryISO))completion
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            completion (NO,((CLPlacemark *)[placemarks lastObject]).ISOcountryCode);
        }
        else {
            completion (YES, nil);
        }
    }];
}

#pragma mark - Private

- (NSTimeInterval)detectingInterval
{
	NSTimeInterval interval = [CBDateConvertionUtils addMinutes:kLocationManagerActiveModePollingInterval
                                                         toDate:self.activeRegion.enterDate];
	return interval;
}

- (NSString *)regionIDForAirportID:(NSString *)airportID
{
    return [kPrefixLocationRegion stringByAppendingString:airportID];
}

- (NSString *)airportIDFromRegionID:(NSString *)regionID
{
    return [regionID stringByReplacingOccurrencesOfString:kPrefixLocationRegion withString:@""];
}

#pragma mark - Polling For Significant Location Changes

- (void)startPolling
{
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
#if TARGET_IPHONE_SIMULATOR
    [self.locationManager startUpdatingLocation];
#else
    [self.locationManager startMonitoringSignificantLocationChanges];
#endif
}

- (void)stopPolling
{
#if TARGET_IPHONE_SIMULATOR
    [self.locationManager stopUpdatingLocation];
#else
    [self.locationManager stopMonitoringSignificantLocationChanges];
#endif
}

#pragma mark - Region

- (CLRegion *)pollingRegionFromAirport:(DMCheckpoint *)anCheckpoint
{
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(anCheckpoint.latitudeValue, anCheckpoint.longitudeValue)
                                                               radius:kLocationManagerRegionRadius
                                                           identifier:[self regionIDForAirportID:anCheckpoint.ident]];
    return region;
}

- (void)getRegionsForLocationWithCoordinates:(CLLocationCoordinate2D)coordinates completionBlock:(void (^)(BOOL shouldTryToDefineISO))completionHandler
{
    if (coordinates.latitude != kLocationManagerIvalidCoordinateValue || coordinates.longitude != kLocationManagerIvalidCoordinateValue) {
        [self.dataSource locationManager:self
         regionsForGeopointWithLongitude:coordinates.longitude
                                latitude:coordinates.latitude
                       completionHandler:^(NSArray *airports) {
                           [self stopAllRegionsFromPolling];
                           [self.regions removeAllObjects];
                           
                           __block BOOL ISODefinded = NO;
                           [airports enumerateObjectsUsingBlock:^(DMCheckpoint *checkpoint, NSUInteger idx, BOOL *stop) {
                               CLRegion *region = [self pollingRegionFromAirport:checkpoint];
                               if ([region containsCoordinate:self.updatedLocation.clLocation.coordinate]) {
                                   self.activeRegion    = [CBRegion regionWithCLRegion:region enterDate:[NSDate date]];
                                   self.pollingMode     = CBLocationManagerPollingModeInAirport;
                                   
                                   self.updatedLocation.countryISO = checkpoint.country.identifier;
                                   ISODefinded = YES;
                                   *stop = YES;
                               }
                               else {
                                   [self.regions addObject:region];
                               }
                           }];
                           if (self.pollingMode != CBLocationManagerPollingModeInAirport) {
                               self.pollingMode  = CBLocationManagerPollingModeNormal;
                           }
                           completionHandler (!ISODefinded);
                       }];
    }
    else
        completionHandler (YES);
}

- (BOOL)isAlreadyPollingRegion:(CLRegion *)region
{
    __block BOOL retBool = NO;
    [[self.locationManager monitoredRegions] enumerateObjectsUsingBlock:^(CLRegion *monitoredRegion, BOOL *stop) {
        if ([region.identifier isEqualToString:region.identifier])  {
            retBool = YES;
            *stop   = YES;
        }
    }];
    return retBool;
}

- (void)stopAllRegionsFromPolling
{
    NSSet *regions = [self.locationManager monitoredRegions];
    for (CLRegion *regionObj in regions) {
        if ([regionObj.identifier rangeOfString:kPrefixLocationRegion].location > 0){
            [self.locationManager stopMonitoringForRegion:regionObj];
        }
    }
}

- (void)startRegionPollingForRegions:(NSArray *)regions
{
	for (CLRegion *region in regions) {
		if (![self isAlreadyPollingRegion:region])
            [self.locationManager startMonitoringForRegion:region];
	}
}

- (void)airportDetected:(CLRegion *)region
{
	if (self.pollingMode == CBLocationManagerPollingModeDetectingAirport) {
		self.pollingMode =  CBLocationManagerPollingModeInAirport;
	}
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSArray *locArray = @[newLocation];
    [self locationManager:manager didUpdateLocations:locArray];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = locations [0];
    self.updatedLocation = [CBLocation locationWithCLLocation:newLocation countryISOCode:nil];
	if (self.updatedLocation) {
        __block UIBackgroundTaskIdentifier bgTask = UIBackgroundTaskInvalid;
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }];
        }
        
		[self getRegionsForLocationWithCoordinates:self.updatedLocation.clLocation.coordinate
                                   completionBlock:^(BOOL shouldTryToDefineISO)
        {
            if (![self.updatedLocation ISOCodeSpecified] || shouldTryToDefineISO) {
                [self geocodeLocation:newLocation completionHandler:^(BOOL error, NSString *countryISO)
            {
                if (countryISO) {
                    self.updatedLocation.countryISO = countryISO;
                    if (!self.currentLocation || ![self.currentLocation.countryISO isEqualToString:self.updatedLocation.countryISO]) {
                        [self.delegate locationManager:self didDetectCountryWithISOCode:self.updatedLocation.countryISO];
                    }
                    self.currentLocation = self.updatedLocation;
                }
                }];
            }
            else {
                if (!self.currentLocation || ![self.currentLocation.countryISO isEqualToString:self.updatedLocation.countryISO]) {
                    [self.delegate locationManager:self didDetectCountryWithISOCode:self.updatedLocation.countryISO];
                }
                self.currentLocation = self.updatedLocation;
            }
            if (bgTask != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        }];
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if ((status != self.authorizationStatus) || (status == kCLAuthorizationStatusNotDetermined)) {
		self.authorizationStatus = status;
		[self refreshAutorizationStatus];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.delegate locationManager:self didFailWithError:error authorizationError:NO];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	if ([self isAlreadyPollingRegion:region])   {
		self.activeRegion = [CBRegion regionWithCLRegion:region enterDate:[NSDate date]];
		if (self.pollingMode != CBLocationManagerPollingModeDetectingAirport || self.pollingMode == CBLocationManagerPollingModeInAirport) {
			self.pollingMode = CBLocationManagerPollingModeDetectingAirport;
		}
	}
}

@end

//
//  CBLocationManager.h
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 6/11/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMManager.h"

FOUNDATION_EXPORT NSString * const keyLocationManagerAirportID;
FOUNDATION_EXPORT NSString * const keyLocationManagerLatitude;
FOUNDATION_EXPORT NSString * const keyLocationManagerLongitude;

@class CBLocationManager, CBLocation;
@protocol CBLocationManagerDataSource <NSObject>

/*!
 @method        locationManager:regionsForGeopointWithLongitude:latitude:completionHandler:
 @discussion    Location manager asks datasource to provide data for region polling. Regions may be filtered by distance from geopoint with provided latitude && longitude.
                completionHandler must not be nil (but you can pass nil as a parametr)
*/
- (void)locationManager:(CBLocationManager *)manager regionsForGeopointWithLongitude:(CLLocationDegrees)longitude
			   latitude:(CLLocationDegrees)latitude
	  completionHandler:(void (^)(NSArray *airports))completionHandler;

@end

@protocol CBLocationManagerDelegate <NSObject>

/*!
 @method        locationManager:didFailWithError:authorizationError:
 @discussion    Signals that something went wrong with location detection if authorizationError == YES than user disabled location services for app
*/
- (void)locationManager:(CBLocationManager *)manager
       didFailWithError:(NSError *)error
     authorizationError:(BOOL)authorization;

/*!
 @method        locationManager:willStartDetectingAirportWithID:
 @discussion    Informs delegate that location service did detect airport, but will not enter airport mode until specified time (30 min) expire
*/
- (void)locationManager:(CBLocationManager *)manager willStartDetectingAirportWithID:(NSString *)airportID;

/*!
 @method     locationManager:didDetectAirportWithID:
 @discussion Informs delegate that user spend more than 30 min in airport, so it should handle this situation
*/
- (void)locationManager:(CBLocationManager *)manager didDetectAirportWithID:(NSString *)airportID;

/*!
 @method        locationManager:didDetectCountryWithISOCode:
 @abstract      Informs delegate about detecting country with ISO code
 @discussion    If user doesn't enter polled region, but location manager detects significant location changes, than manager will try 
                to geocode current location to get country ISO Code and pass it to delegate.    
                Note: ISO code geocoding will work only with live Internet connection
*/
- (void)locationManager:(CBLocationManager *)manager didDetectCountryWithISOCode:(NSString *)anISOCode;

@end

@interface CBLocationManager : NSObject

@property (weak, nonatomic) id <CBLocationManagerDataSource> dataSource;
@property (weak, nonatomic) id <CBLocationManagerDelegate> delegate;

@property (strong, readonly, nonatomic) CBLocation *currentLocation;

/*!
 @method     switchLocationManagerInForegroundMode
 @discussion switch polling mode depend on current app state
*/
- (void)switchLocationManagerInForegroundMode;
- (void)switchLocationManagerToBackgroundMode;

- (void)stopAllActivities;
- (void)resumeAllActivities;

@end

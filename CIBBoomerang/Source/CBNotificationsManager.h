//
//  CBNotificationsManager.h
//  CIBBoomerang
//
//  Created by Roma on 5/21/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @discussion NSNotification object, posted when CBNotificationsManager handles ReminderNotidication
                userInfo NSDicationary contains:
                carnetID for key keyCBCarnetNotificationCarnetId    - DMCarnet object identifier
 */
FOUNDATION_EXPORT NSString *const CBNotificationsManagerHandleReminderNotification;
FOUNDATION_EXPORT NSString *const keyCBCarnetNotificationCarnetId;


/**
 *  @discussion NSNotification object, posted when CBNotificationsManager handles TravelDayNotification
                userInfo NSDictionary contains:
                travelDate for key keyCBCarnetNotificationDate      - NSDate object
 */
FOUNDATION_EXPORT NSString *const CBNotificationsManagerHandleTravelDayNotification;
FOUNDATION_EXPORT NSString *const keyCBCarnetNotificationDate;

FOUNDATION_EXPORT NSString *const CBNotificationsManagerHandleCountryNotification;
FOUNDATION_EXPORT NSString *const keyCBCarnetNotificationCountryISO;


@interface CBNotificationsManager : NSObject

/**
 *  @method             scheduleReminderNotificationForCarnet:fireDate:
 *  @abstract           Schedule notification that reminds user to add travel plans for carnet
 *  @discussion         Notification Manager checks if there is no notification already has been scheduled.
 *                      If there are this method doesn't schedule anything.
 *  @param guid         NSString carnet guid
 *  @param aCarnetID    NSString, carnet identifier
 *  @param fireDate     date when notification should be fired, date must not be nil
 */
+ (void)scheduleReminderNotificationForCarnetWithGUID:(NSString*)guid carnetId:(NSString *)aCarnetID fireDate:(NSDate *)fireDate;

/**
 *  @method             scheduleTravelDayNotificationForDate:
 *  @abstract           Schedule travel day notification for provided date
 *  @discussion         Notification Manager checks if there is no notification alreday has been scheduled for this date.
 *                      Otherwise it won't schedule any.
 *  @param travelDate   date of travel, must not be nil
 */
+ (void)scheduleTravelDayNotificationForDate:(NSDate *)travelDate;

/**
 * @method              presentCountryChangeNotification:
 * @abstract            Present notification when user changed country in background
 * @discussion          Present notification
 * @param countryISOCode New country ISO code
 */
+ (void)presentCountryChangeNotification:(NSString*)countryISOCode;

/**
 *  @method                 handleLocalNotification:
 *  @abstract               Notification Manager parses aNotification userInfo dictionary and notifies observers with specified notification.
 *  @param aNotification    UILocalNotification object
 */
+ (void)handleLocalNotification:(UILocalNotification *)aNotification;

/**
 *  @method         cancelNotificationsForCarnetWithID:
 *  @abstract       cancel all UILocalNotifications related to carnet
 *  @param carnet   NSString carnetID, must not be nil
 */
+ (void)cancelNotificationsForCarnetWithID:(NSString *)carnetID;

/**
 *  @method         cancelTravelDateNotifications:
 *  @abstract       cancel all UILocalNotifications related to provided travel date
 *  @param aDate    NSDate object, must not be nil
 */
+ (void)cancelTravelDateNotifications:(NSDate *)aDate;

#ifdef DEBUG
+ (void)deleteAll;
#endif

+ (NSDate *)scheduledTravelDate;

@end

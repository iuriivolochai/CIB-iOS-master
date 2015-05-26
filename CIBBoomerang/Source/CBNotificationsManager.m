//
//  CBNotificationsManager.m
//  CIBBoomerang
//
//  Created by Roma on 5/21/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBNotificationsManager.h"
#import "DMCarnet+Auxilliary.h"
#import "CBAlertsManager.h"

NSString *const keyCBCarnetNotificationNotificationType = @"notificationType";
NSString *const keyCBCarnetNotificationDate             = @"date";
NSString *const keyCBCarnetNotificationCarnetId         = @"identifier";
NSString *const keyCBCarnetNotificationCountryISO       = @"countryISO";

NSString *const CBNotificationsManagerHandleReminderNotification    = @"CBNotificationsManagerHandleReminderNotification";
NSString *const CBNotificationsManagerHandleTravelDayNotification   = @"CBNotificationsManagerHandleTravelDayNotification";
NSString *const CBNotificationsManagerHandleCountryNotification     = @"CBNotificationsManagerHandleCountryNotification";

typedef NS_ENUM(NSUInteger, CBNotificationsManagerNotificationType) {
    CBNotificationsManagerNotificationTypeDateReminder = 0,
    CBNotificationsManagerNotificationTypeTravellDay,
    CBNotificationsManagerNotificationTypeCountry
};

@interface CBNotificationsManager ()

@end

@implementation CBNotificationsManager

+ (CBNotificationsManager *)sharedManager
{
    static dispatch_once_t once;
    static CBNotificationsManager *instance;
    dispatch_once(&once, ^ {
        instance = [[CBNotificationsManager alloc] init];
    });
    return instance;
}

#pragma mark - Public

+ (void)deleteAll
{
    UIApplication *application = [UIApplication sharedApplication];
    [application cancelAllLocalNotifications];
}

+ (void)scheduleReminderNotificationForCarnetWithGUID:(NSString*)guid carnetId:(NSString *)aCarnetID fireDate:(NSDate *)fireDate
{
    if (![self reminderNotificationExistForCarnetWithID:guid]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        notification.fireDate           = fireDate;
        notification.timeZone           = [NSTimeZone systemTimeZone];
        notification.alertAction        = NSLocalizedString(@"View Details", @"Reminder notification alert action");
        notification.alertBody          = [NSString stringWithFormat:@"Travel plan reminder for %@ with identifier %@", NSLocalizedString(@"Carnet", nil), aCarnetID];
        notification.alertLaunchImage   = @"Icon-Small";
        notification.soundName          = UILocalNotificationDefaultSoundName;
        
        
        NSDictionary *infoDict = @{keyCBCarnetNotificationCarnetId          : guid,
                                   keyCBCarnetNotificationNotificationType  : @(CBNotificationsManagerNotificationTypeDateReminder)};
        notification.userInfo = infoDict;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

+ (void)scheduleTravelDayNotificationForDate:(NSDate *)travelDate
{
    if (![self departureNotificationExistForDate:travelDate]) {
		UILocalNotification *notification = [[UILocalNotification alloc] init];
        
		notification.fireDate           = travelDate;
		notification.timeZone           = [NSTimeZone systemTimeZone];
		notification.alertAction        = NSLocalizedString(@"View Details", @"Travel day notification alert action");
        notification.alertBody          = NSLocalizedString(@"", @"Travel day notification alert body");
		notification.alertLaunchImage   = @"Icon-Small";
		
		NSDictionary *infoDict = @{ keyCBCarnetNotificationNotificationType  : @(CBNotificationsManagerNotificationTypeTravellDay),
                                    keyCBCarnetNotificationDate              : travelDate};
        
		notification.userInfo = infoDict;
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	}
}

+ (void)presentCountryChangeNotification:(NSString*)countryISOCode
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertAction            = NSLocalizedString(@"Check carnets", @"Check carnets on country update in bakground");
    NSString *retString                 = [CBAlertsManager textForAlertWithType:CBLocationAlertType_Validation];
    notification.alertBody              = [NSString stringWithFormat:retString, countryISOCode];
    
    
    NSDictionary *infoDict = @{ keyCBCarnetNotificationNotificationType: @(CBNotificationsManagerNotificationTypeCountry),
                                keyCBCarnetNotificationCountryISO      : countryISOCode};
    
    notification.userInfo = infoDict;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

+ (void)handleLocalNotification:(UILocalNotification *)localNotification
{
    NSDictionary *userInfo;
    NSString *notificationName;
    
	CBNotificationsManagerNotificationType type = [localNotification.userInfo[keyCBCarnetNotificationNotificationType] integerValue];
	switch (type) {
		case CBNotificationsManagerNotificationTypeDateReminder: {
            NSString *carnetID  = localNotification.userInfo[keyCBCarnetNotificationCarnetId];
            userInfo            = @{keyCBCarnetNotificationCarnetId : carnetID};
            notificationName    = CBNotificationsManagerHandleReminderNotification;
        }
			break;
		case CBNotificationsManagerNotificationTypeTravellDay: {
            NSDate *travelDate  = localNotification.userInfo[keyCBCarnetNotificationDate];
            userInfo            = @{keyCBCarnetNotificationDate : travelDate};
            notificationName    = CBNotificationsManagerHandleTravelDayNotification;
		}
			break;
        case CBNotificationsManagerNotificationTypeCountry: {
            NSString *isoCode   = localNotification.userInfo[keyCBCarnetNotificationCountryISO];
            userInfo            = @{keyCBCarnetNotificationCountryISO: isoCode};
            notificationName    = CBNotificationsManagerHandleCountryNotification;
        }
            break;
	}
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
    });
}

+ (void)cancelNotificationsForCarnetWithID:(NSString *)aCarnetID
{
    UIApplication *application = [UIApplication sharedApplication];
    for (UILocalNotification *locNotification in [application scheduledLocalNotifications]) {
        NSString *carnetID = locNotification.userInfo[keyCBCarnetNotificationCarnetId];
        if (carnetID.length && [carnetID isEqualToString:aCarnetID]) {
            [application cancelLocalNotification:locNotification];
        }
    }
}

+ (void)cancelTravelDateNotifications:(NSDate *)aDate
{
    UIApplication *application = [UIApplication sharedApplication];
    for (UILocalNotification *locNotification in [application scheduledLocalNotifications]) {
        NSDate *locNotificationDate = locNotification.userInfo[keyCBCarnetNotificationDate];
        if (locNotificationDate && [locNotificationDate compare:aDate] == NSOrderedSame) {
            [application cancelLocalNotification:locNotification];
        }
    }
}

#pragma mark - Private

+ (BOOL)departureNotificationExistForDate:(NSDate *)fireDate
{
	__block BOOL exist = NO;
	UIApplication *application = [UIApplication sharedApplication];
    [[application scheduledLocalNotifications] enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        if ([fireDate compare:notification.userInfo[keyCBCarnetNotificationDate]] == NSOrderedSame) {
			exist = YES;
			*stop = YES;
        }
    }];
	return exist;
}

+ (BOOL)reminderNotificationExistForCarnetWithID:(NSString *)carnetID
{
    __block BOOL exist = NO;
	UIApplication *application = [UIApplication sharedApplication];
    [[application scheduledLocalNotifications] enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        if ([carnetID isEqualToString:notification.userInfo[keyCBCarnetNotificationCarnetId]]) {
			exist = YES;
			*stop = YES;
        }
    }];
	return exist;
}

+ (NSDate *)scheduledTravelDate
{
    __block NSDate *retDate;
	UIApplication *application = [UIApplication sharedApplication];
    [[application scheduledLocalNotifications] enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        NSDate *locNotificationDate = notification.userInfo[keyCBCarnetNotificationDate];
        if (locNotificationDate) {
            retDate = locNotificationDate;
            *stop = YES;
        }
    }];
    return retDate;
}

@end

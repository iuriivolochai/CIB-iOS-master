//
//  CBAlertsTextUtil.h
//  CIBBoomerang
//
//  Created by Roma on 6/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const keyCBAlertsSettingsUtilText;
FOUNDATION_EXPORT NSString *const keyCBAlertsSettingsUtilPriority;
FOUNDATION_EXPORT NSString *const keyCBAlertsSettingsUtilOccuranceType;
FOUNDATION_EXPORT NSString *const keyCBAlertsSettingsUtilButtons;

FOUNDATION_EXPORT NSString *const keyButtonText;
FOUNDATION_EXPORT NSString *const keyButtonImageName;

@interface CBAlertsSettingsUtil : NSObject

+ (NSDictionary *)aiportAlertSettings;

+ (NSDictionary *)countryAlertSettings;

+ (NSDictionary *)locationAlertSettings:(CBAlertType)type
                               location:(NSString *)location
                           nextLocation:(NSString *)nextLocation
                           carnetNumber:(NSString *)number;

+ (NSDictionary *)simpleAlertSettings:(CBAlertType)type
                     carnetIdentifier:(NSString *)identifier;


+ (NSDictionary *)alertButtonsSettings:(CBAlertButtonType)type alertPriority:(NSUInteger)priority;


@end

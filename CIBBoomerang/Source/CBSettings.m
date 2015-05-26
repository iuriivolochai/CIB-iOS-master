//
//  CBSettings.m
//  CIBBoomerang
//
//  Created by Roma on 5/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBSettings.h"

NSString *const keyCBSettingsAlerts = @"keyCBSettingsAlerts";
NSString *const keyCBSettingsSounds = @"keyCBSettingsSounds";
NSString *const keyCBSettingsWifiOnly = @"keyCBSettingsWifiOnly";

@interface CBSettings ()

@end

@implementation CBSettings

static NSDictionary *defaultSettings = nil;

#pragma mark - Public

+ (void)turnBasicAlertsOn:(BOOL)on
{
    [CBSettings turnSettingsOption:keyCBSettingsAlerts on:on];
}

+ (void)turnSoundsOn:(BOOL)on
{
    [CBSettings turnSettingsOption:keyCBSettingsSounds on:on];
}

+ (void)turnWifiOnlyOn:(BOOL)on
{
    [CBSettings turnSettingsOption:keyCBSettingsWifiOnly on:on];
}

+ (BOOL)basicAlertsOn
{
    return [CBSettings settingsOptionValue:keyCBSettingsAlerts];
}

+ (BOOL)soundsOn
{
    return [CBSettings settingsOptionValue:keyCBSettingsSounds];
}

+ (BOOL)wifiOnlyOn
{
    return [CBSettings settingsOptionValue:keyCBSettingsWifiOnly];
}

#pragma mark - Private

+ (void)turnSettingsOption:(NSString *)option on:(BOOL)on
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:option];
    [defaults synchronize];
}

+ (BOOL)settingsOptionValue:(NSString *)option
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [defaults objectForKey:option];
    
    if (!value) {
        value = [self defaultSettings][option];
    }
    
    return [value boolValue];
}

+ (NSDictionary *)defaultSettings
{
    if (!defaultSettings) {
        NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"default_settings" ofType:@"plist"];
        defaultSettings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
    }
    
    return defaultSettings;
}

@end

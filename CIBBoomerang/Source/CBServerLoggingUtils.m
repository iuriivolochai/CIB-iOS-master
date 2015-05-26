//
//  CBLogUtils.m
//  CIBBoomerang
//
//  Created by Roma on 6/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBServerLoggingUtils.h"
#import "NSString+MD5Addition.h"
#import "KeychainItemWrapper.h"

NSString *const keyCustomUDID = @"CustomUDID";

NSString *const keyActionCountryId = @"CountryId";
NSString *const keyActionData = @"Data";
NSString *const keyActionDate = @"Date";
NSString *const keyActionDeviceId = @"DeviceId";
NSString *const keyActionGUID = @"CarnetGuid";
NSString *const keyActionLatitude = @"Latitude";
NSString *const keyActionLogs = @"Logs";
NSString *const keyActionLongitude = @"Longitude";
NSString *const keyActionName = @"Action";
NSString *const keyActionTimezone = @"Timezone";
NSString *const keyActionVersion = @"Version";

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation CBServerLoggingUtils

static KeychainItemWrapper *keychainItemWrapper = nil;

#define kActionsName @[@"SCAN",@"VERIFY",@"ADD",@"REJECT",@"DELETE",@"TRAVEL_PLAN_ADD",@"TRAVEL_PLAN_DELETE",@"SPLIT_ACCEPT",@"SPLIT_CANCEL",@"JOIN",@"JOIN_CANCEL",@"EXPIRED",@"LOW_FOILS",@"COUNTRY_CHANGED",@"WRONG_COUNTRY",@"AIRPORT_DETECTED",@"UNSUCCESSFUL_SCAN",@"RESCAN_PROMPT",@"TRAVELLING_SOON_PROMPT"]

+ (NSString *)actionNameForIndex:(DMLoggedActionType)index
{
    return [kActionsName objectAtIndex:index];
}

+ (NSString *)deviceId
{
    //    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    //    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    //    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    //    NSString *uniqueIdentifier = [stringToHash stringFromMD5];
    //    return uniqueIdentifier;
    
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
    
    /*NSString *udid = [self customUDID];
    DDLogVerbose(@"UDID = %@", udid);
    return udid;*/
}

+ (NSInteger)timezoneOffset
{
    return [[NSTimeZone systemTimeZone] secondsFromGMT];
}

#pragma mark - Private

+ (KeychainItemWrapper *)keychainItemWrapper
{
    if (!keychainItemWrapper) {
        keychainItemWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"cibboomerang.com.waverleysoftware.GenericKeychainSuite" accessGroup:nil];
    }
    
    return keychainItemWrapper;
}

+ (NSString *)customUDID
{
    NSString *customUDID = [[self keychainItemWrapper] objectForKey:(__bridge id)kSecAttrAccount];
    
    if (!customUDID || (customUDID.length == 0)) {
        customUDID = [self generateUUID];
        [[self keychainItemWrapper] setObject:customUDID forKey:(__bridge id)kSecAttrAccount];
    }
    
    return customUDID;
}

+ (NSString *)generateUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end

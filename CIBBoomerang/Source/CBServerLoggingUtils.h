//
//  CBLogUtils.h
//  CIBBoomerang
//
//  Created by Roma on 6/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const keyActionCountryId;
FOUNDATION_EXPORT NSString *const keyActionData;
FOUNDATION_EXPORT NSString *const keyActionDate;
FOUNDATION_EXPORT NSString *const keyActionDeviceId;
FOUNDATION_EXPORT NSString *const keyActionGUID;
FOUNDATION_EXPORT NSString *const keyActionLatitude;
FOUNDATION_EXPORT NSString *const keyActionLongitude;
FOUNDATION_EXPORT NSString *const keyActionLogs;
FOUNDATION_EXPORT NSString *const keyActionName;
FOUNDATION_EXPORT NSString *const keyActionTimezone;
FOUNDATION_EXPORT NSString *const keyActionVersion;

typedef NS_ENUM(int, DMLoggedActionType) {
    DMLoggedActionTypeScan = 0,//+
    DMLoggedActionTypeVerify,//+
    DMLoggedActionTypeAdd,//+
    DMLoggedActionTypeReject,//+
    DMLoggedActionTypeDelete,//+
    DMLoggedActionTypeTravelPlanAdd,//+
    DMLoggedActionTypeTravelPlanDelete,//+
    DMLoggedActionTypeSplit,//+
    DMLoggedActionTypeSplitCancel,//+
    DMLoggedActionTypeReconstitute,//+
    DMLoggedActionTypeReconstituteCancel,//+
    DMLoggedActionTypeExpired,//+
    DMLoggedActionTypeLowFoils,//+
    DMLoggedActionTypeCountryChanged,//+
    DMLoggedActionTypeWrongCountry,//+
    DMLoggedActionTypeAirportDetected,//+
    DMLoggedActionTypeUnsuccessfulScan,//+
    DMLoggedActionTypeRescanPrompt,//+
    DMLoggedActionTypeTravellingSoonPrompt,//+
};

@interface CBServerLoggingUtils : NSObject

+ (NSString *)actionNameForIndex:(DMLoggedActionType)index;
+ (NSString *)deviceId;
+ (NSInteger)timezoneOffset;

@end

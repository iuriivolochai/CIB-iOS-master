//
//  CBTypes.h
//  CIBBoomerang
//
//  Created by Roma on 4/24/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CBSimpleCompletionBlock)     (BOOL completed);
typedef void (^CBCompletionWithErrorBlock)  (BOOL completed, NSError *error);

typedef NS_ENUM(int16_t, CBConnectionManagerResponseStatus) {
    CBConnectionManagerResponseStatusSucess = 200,
    CBConnectionManagerResponseStatusUpdated = 204,
    CBConnectionManagerResponseStatusInvalidRequest = 400,
    CBConnectionManagerResponseStatusNoCarnet = 404,
    CBConnectionManagerResponseStatusConflict = 409,
    CBConnectionManagerResponseStatusAlreadyTracked = 422,
    CBConnectionManagerResponseStatusError = 500
};

typedef NS_ENUM(NSUInteger, CBAlertOccuranceType) {
        CBAlertOccuranceType_Regular = 0,
        CBAlertOccuranceTypePopup
};

typedef NS_ENUM (NSUInteger, CBAlertType) {
    
    CBAlertType_AiportAlert                         = 1,
    CBAlertType_CountryAlert                        = 2,
    
    CBLocationAlertType_Travelling_All_Items    = 1001,
    CBLocationAlertType_Validation_US           = 1002,
    CBLocationAlertType_Stamp                   = 1003,
    CBLocationAlertType_Reconstitute            = 1004,
    CBLocationAlertType_Remove_USA              = 1005,
    CBLocationAlertType_Validation              = 1006,
    CBLocationAlertType_Wrong_Country           = 1007,
    CBLocationAlertType_Scan                    = 1008,
    CBLocationAlertType_UnknowError             = 1009,
    CBLocationAlertType_Accompany               = 1010,
    
    CBSimpleAlertType_Warning_Signed                = 2001,
    CBSimpleAlertType_Warning_LowFoils              = 2002,
    CBSimpleAlertType_Warning_Expiring              = 2003,
    CBSimpleAlertType_Error_LowFoils                = 2004,
    CBSimpleAlertType_Error_Expiring                = 2005,
    CBSimpleAlertType_Popup_WillYouBeTravellingSoon = 2006,
    CBSimpleAlertType_Warning_Verify                = 2007
    
};

typedef NS_ENUM (NSUInteger, CBAlertButtonType) {
        CBAlertButtonType_YES = 0,
        CBAlertButtonType_NO,
        CBAlertButtonType_Dismiss,
        CBAlertButtonType_Accept,
        CBAlertButtonType_Reject,
        CBAlertButtonType_Scan,
        CBAlertButtonType_Call,
        CBAlertButtonType_TakeAll,
        CBAlertButtonType_Reconstitute
};

typedef NS_ENUM(NSUInteger, DMCarnetStatus) {
        DMCarnetStatusOpen = 0,
        DMCarnetStatusActive,
        DMCarnetStatusSplit,
        DMCarnetStatusSplitWarning,
        DMCarnetStatusVerifyWarning,
        DMCarnetStatusCountryWarning,
        DMCarnetStatusWarning,
        DMCarnetStatusLowFoilsWarning,
        DMCarnetStatusExpireWarning,
        DMCarnetStatusUnknownError,
        DMCarnetStatusCountryError,
        DMCarnetStatusLowFoilsError,
        DMCarnetStatusExpireError
};

typedef NS_ENUM(NSUInteger, DMWaypointKind) {
        DMWaypointKindNone = 0,
        DMWaypointKindStartpoint = 2,
        DMWaypointKindVisit = 4,
        DMWaypointKindTransit = 8,
        DMWaypointKindEndpoint = 16
};

typedef NS_ENUM(NSUInteger, DMWaypointStatus) {
        DMWaypointStatusQueued = 0,
        DMWaypointStatusPassed
};

typedef NS_ENUM(NSUInteger, DMManagerAlertHandlingAction) {
    DMManagerAlertHandlingAction_Dismiss,
    DMManagerAlertHandlingAction_Scan,
    DMManagerAlertHandlingAction_PopController,
    DMManagerAlertHandlingAction_ShowTravelDetailsScreen,
    DMManagerAlertHandlingAction_ShowReminderPicker,
    DMManagerAlertHandlingAction_ShowPopoverAlerts
};

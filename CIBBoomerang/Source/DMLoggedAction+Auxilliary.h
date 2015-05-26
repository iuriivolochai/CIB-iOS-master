//
//  DMLoggedAction+Auxilliary.h
//  CIBBoomerang
//
//  Created by Roma on 6/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMLoggedAction.h"

typedef NS_ENUM(int, DMLoggedActionType) {
    DMLoggedActionTypeVerify = 0,
    DMLoggedActionTypeReject,
    DMLoggedActionTypeDelete,
    DMLoggedActionTypeTravelPlanAdd,
    DMLoggedActionTypeTravelPLanDelete,
    DMLoggedActionTypeSplit,
    DMLoggedActionTypeSplitCancel,
    DMLoggedActionTypeReconsttiute,
    DMLoggedActionTypeReconsttiuteCancel,
    DMLoggedActionTypeExpired,
    DMLoggedActionTypeLowFoils,
    DMLoggedActionTypeCountryChanged,
    DMLoggedActionTypeWrongCountry,
    DMLoggedActionTypeAirportDetected,
};

@interface DMLoggedAction (Auxilliary)

+ (NSString *)actionNameForIndex:(DMLoggedActionType)actionType;

@end

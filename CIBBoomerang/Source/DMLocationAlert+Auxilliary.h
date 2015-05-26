//
//  DMLocationAlert+Auxilliary.h
//  CIBBoomerang
//
//  Created by Roma on 6/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMLocationAlert.h"
#import "CBAlertObjectProtocol.h"

FOUNDATION_EXPORT   NSString *const DMLocationAlertShownKey;
FOUNDATION_EXPORT   NSString *const DMLocationAlertPriority;
FOUNDATION_EXPORT   NSString *const DMLocationAlertOccurence;

@interface DMLocationAlert (Auxilliary) <CBAlertObjectProtocol>

/**
 *  @method         obtainLocationAlertWithType:
 *  @abstract       returns newly created DMLocationAlert object
 *  @param aType    CBAlertType enum
 *  @return DMLocationAlert object
 */
+ (DMLocationAlert *)obtainLocationAlertWithType:(CBAlertType)aType;

+ (id)alertFromParametrs:(NSDictionary *)aParametrs;

@end

//
//  DMSimpleAlert+Auxilliary.h
//  CIBBoomerang
//
//  Created by Roma on 6/20/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMSimpleAlert.h"
#import "CBAlertObjectProtocol.h"

FOUNDATION_EXPORT NSString *const keyDMSimpleAlertShow;
FOUNDATION_EXPORT NSString *const keyDMSimpleAlertOccuranceType;
FOUNDATION_EXPORT NSString *const DMSimpleAlertType;

@interface DMSimpleAlert (Auxilliary) <CBAlertObjectProtocol>

/**
 *  @method         obtainNewSimpleAlertWithType:
 *  @abstract       returns new simple alert object with specified type
 *  @param aType    enum for CBAlertType
 *
 *  @return DMSimpleAlert object
 */
+ (instancetype)obtainNewSimpleAlertWithType:(CBAlertType)aType;

@end

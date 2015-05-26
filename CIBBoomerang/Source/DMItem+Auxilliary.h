//
//  DMItem+Auxilliary.h
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 4/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMItem.h"

FOUNDATION_EXPORT NSString * const keyDMItemGlobalIdentifier;
FOUNDATION_EXPORT NSString * const keyDMItemCountry;
FOUNDATION_EXPORT NSString * const keyDMItemIdentifier;
FOUNDATION_EXPORT NSString * const keyDMItemSpecification;
FOUNDATION_EXPORT NSString * const keyDMItemQuantity;
FOUNDATION_EXPORT NSString * const keyDMItemValue;
FOUNDATION_EXPORT NSString * const keyDMItemWaypoint;
FOUNDATION_EXPORT NSString * const keyDMItemWeight;

@class DMWaypoint;

@interface DMItem (Auxilliary)

+ (DMItem *)newItemWithIdentifier:(int16_t)identifier;
+ (DMItem *)newItemWithData:(NSDictionary *)itemData carnet:(DMCarnet *)carnet;
+ (DMItem *)itemForCarnet:(DMCarnet *)carnet withItemId:(NSString *)itemId;

@end

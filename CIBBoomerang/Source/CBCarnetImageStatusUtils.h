//
//  CBCarnetImageStatusUtils.h
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 6/17/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const keyCBCarnetStatusImage;
FOUNDATION_EXPORT NSString *const keyCBCarnetStatusBackgroundImage;
FOUNDATION_EXPORT NSString *const keyCBCarnetStatusText;
FOUNDATION_EXPORT NSString *const keyCBCarnetStatusTextLabel;
FOUNDATION_EXPORT NSString *const keyCBCarnetStatusTextColor;

@class DMCarnet;

@interface CBCarnetImageStatusUtils : NSObject

/* Returns status text, status image, status text color. Optionally returns overlay picture (e.g. "exclamation pointer" image) and overlay label (e.g. "US" label) */
+ (NSDictionary *)statusDictionatyForCarnet:(DMCarnet *)carnet;

@end

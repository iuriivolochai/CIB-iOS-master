//
//  CBAlertsManager.h
//  CIBBoomerang
//
//  Created by Roma on 9/3/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBTypes.h"

@interface CBAlertsManager : NSObject

+ (NSString *)textForAlertWithType:(CBAlertType)aType;
+ (void)updateAlertsPlist;

#pragma mark for UnitTesting
+ (void)updateAlertsPlistFromDictionary:(NSDictionary *)alertsDic isErrorOccurred:(BOOL)isErrorOccurred;

@end

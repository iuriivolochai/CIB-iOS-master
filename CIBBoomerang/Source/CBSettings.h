//
//  CBSettings.h
//  CIBBoomerang
//
//  Created by Roma on 5/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBSettings : NSObject

+ (void)turnBasicAlertsOn:(BOOL)on;
+ (void)turnSoundsOn:(BOOL)on;
+ (void)turnWifiOnlyOn:(BOOL)on;

+ (BOOL)basicAlertsOn;
+ (BOOL)soundsOn;
+ (BOOL)wifiOnlyOn;

@end

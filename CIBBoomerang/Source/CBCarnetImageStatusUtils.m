//
//  CBCarnetImageStatusUtils.m
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 6/17/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCarnetImageStatusUtils.h"
#import "DMManager.h"

NSString *const keyCBCarnetStatusImage = @"statusImageName";
NSString *const keyCBCarnetStatusBackgroundImage = @"statusBgImage";
NSString *const keyCBCarnetStatusText = @"statusText";
NSString *const keyCBCarnetStatusTextLabel = @"statusTextLabel";
NSString *const keyCBCarnetStatusTextColor = @"textColor";

@implementation CBCarnetImageStatusUtils

+ (NSDictionary *)statusDictionatyForCarnet:(DMCarnet *)carnet
{
	NSDictionary *retDic;
	switch (carnet.carnetStatus) {
		case DMCarnetStatusActive: {
			retDic = @{ keyCBCarnetStatusBackgroundImage : @"icon-status-0",
                        keyCBCarnetStatusTextLabel : @"Active",
                        keyCBCarnetStatusTextColor : [UIColor colorWithRed:0.f  green:72./255.f blue:72./255.f alpha:1.f]};
		}
			break;
		case DMCarnetStatusOpen: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"icon-open",
                            keyCBCarnetStatusTextLabel : @"Open",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:0.f  green:72./255.f blue:72./255.f alpha:1.f]};
		}
			break;
		case DMCarnetStatusSplit: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"icon-status-1",
                            keyCBCarnetStatusTextLabel : @"Split",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:0.f  green:72./255.f blue:72./255.f alpha:1.f]};
		}
			break;
		case DMCarnetStatusSplitWarning: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"icon-status-open-splt",
                            keyCBCarnetStatusTextLabel : @"Split",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:212.f/255.f  green:162./255.f blue:36./255.f alpha:1.f]};
		}
			break;
        case DMCarnetStatusCountryWarning: {
            retDic = @	{	keyCBCarnetStatusBackgroundImage : @"bg-status-yellow",
                            keyCBCarnetStatusTextLabel  : @"Warning",
                            keyCBCarnetStatusText       : [carnet alertCountryISO],
                            keyCBCarnetStatusTextColor  : [UIColor colorWithRed:212.f/255.f  green:162./255.f blue:36./255.f alpha:1.f]
            };
        }
            break;
            
		case DMCarnetStatusCountryError: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"bg-status-red",
                            keyCBCarnetStatusTextLabel  : @"Error",
                            keyCBCarnetStatusText       : [carnet errorCountryISO],
                            keyCBCarnetStatusTextColor  : [UIColor colorWithRed:235.f/255.f  green:33.f/255.f blue:35.f/255.f alpha:1.f]
            };
		}
			break;
		case DMCarnetStatusExpireError: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"icon-status-5",
                            keyCBCarnetStatusTextLabel : @"Expired",
                            keyCBCarnetStatusText : @"X",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:235.f/255.f  green:33.f/255.f blue:35.f/255.f alpha:1.f]};
		}
			break;
		case DMCarnetStatusExpireWarning: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"bg-status-yellow",
                            keyCBCarnetStatusTextLabel : @"Expiring",
                            keyCBCarnetStatusText : @"X",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:212.f/255.f  green:162./255.f blue:36./255.f alpha:1.f]};
		}
			break;
		case DMCarnetStatusLowFoilsError: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"bg-status-low-foils",
                            keyCBCarnetStatusTextLabel : @"Low Foils",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:235.f/255.f  green:33.f/255.f blue:35.f/255.f alpha:1.f]};
		}           
			break;
		case DMCarnetStatusLowFoilsWarning: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"icon-status-3",
                            keyCBCarnetStatusTextLabel : @"Low Foils",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:212.f/255.f  green:162./255.f blue:36./255.f alpha:1.f]};		}
			break;
		case DMCarnetStatusVerifyWarning: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"icon-status-2",
                            keyCBCarnetStatusTextLabel : @"Verify",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:212.f/255.f  green:162./255.f blue:36./255.f alpha:1.f]};
		}
			break;
		case DMCarnetStatusWarning: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"icon-status-2",
                            keyCBCarnetStatusTextLabel : @"Warning",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:212.f/255.f  green:162./255.f blue:36./255.f alpha:1.f]};		}
			break;
		case DMCarnetStatusUnknownError: {
			retDic = @	{	keyCBCarnetStatusBackgroundImage : @"icon-status-4",
                            keyCBCarnetStatusTextLabel : @"Error",
                            keyCBCarnetStatusTextColor : [UIColor colorWithRed:235.f/255.f  green:33.f/255.f blue:35.f/255.f alpha:1.f]};
		}
	}
	return retDic;
}

@end

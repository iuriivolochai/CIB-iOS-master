//
//  CBAlertsTextUtil.m
//  CIBBoomerang
//
//  Created by Roma on 6/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBAlertsSettingsUtil.h"
#import "CBAlertsManager.h"

NSString *const keyCBAlertsSettingsUtilText = @"ketText";
NSString *const keyCBAlertsSettingsUtilPriority = @"keyPriority";
NSString *const keyCBAlertsSettingsUtilOccuranceType = @"keyOccuranceType";
NSString *const keyCBAlertsSettingsUtilButtons = @"keyButtons";

NSString *const keyButtonText = @"keyButtonText";
NSString *const keyButtonImageName = @"keyButtonImageName";


@implementation CBAlertsSettingsUtil

+ (NSDictionary *)alertButtonsSettings:(CBAlertButtonType)type alertPriority:(NSUInteger)priority
{
    NSString *title;
    NSString *imageName;
    switch (type) {
        case CBAlertButtonType_Accept: {
            title = NSLocalizedString(@"Accept", nil);
            imageName = @"btn-verify-accept";
        }
            break;
        case CBAlertButtonType_Call: {
            title = NSLocalizedString(@"Call", nil);
            imageName = (priority == 1) ? @"btn-red-alert" : @"btn-verify-accept";
        }
            break;
        case CBAlertButtonType_Dismiss: {
            title = NSLocalizedString(@"Ok", nil);
            imageName = (priority == 1) ? @"btn-red-alert" : @"btn-verify-accept";
        }
            break;
        case CBAlertButtonType_Reconstitute: {
            title = NSLocalizedString(@"Reconstitute All", nil);
            imageName = (priority == 1) ? @"btn-red-alert" : @"btn-verify-accept";
        }
            break;
        case CBAlertButtonType_Scan: {
            title = NSLocalizedString(@"Scan Carnet", nil);
            imageName = (priority == 1) ? @"btn-red-alert" : @"btn-verify-accept";
        }
            break;
        case CBAlertButtonType_Reject: {
            title = NSLocalizedString(@"Reject", nil);
            imageName = @"btn-verify-reject";
        }
            break;
        case CBAlertButtonType_TakeAll: {
            title = NSLocalizedString(@"Take All", nil);
            imageName = (priority == 1) ? @"btn-red-alert" : @"btn-verify-accept";
        }
            break;
        case CBAlertButtonType_NO: {
            title = NSLocalizedString(@"NO", nil);
            imageName = @"btn-verify-reject";
        }
            break;
        case CBAlertButtonType_YES: {
            title = NSLocalizedString(@"YES", nil);
            imageName = @"btn-verify-accept";
        }
            break;
    }
    return @{keyButtonImageName : imageName, keyButtonText : title};
}

#pragma mark * Location Alert

+ (NSDictionary *)locationAlertSettings:(CBAlertType)type
                               location:(NSString *)location
                           nextLocation:(NSString *)nextLocation
                           carnetNumber:(NSString *)number
{
    return [self alertSettingsForType:type withLocation:location nextLocation:nextLocation carnetNumber:number];
}

#pragma mark * Simple Alert

+ (NSDictionary *)simpleAlertSettings:(CBAlertType)type carnetIdentifier:(NSString *)identifier
{
    return [self alertSettingsForType:type withLocation:nil nextLocation:nil carnetNumber:identifier];
}

#pragma mark * Airport Alert

+ (NSDictionary *)aiportAlertSettings
{
    return [self alertSettingsForType:CBAlertType_AiportAlert
                         withLocation:nil
                         nextLocation:nil
                         carnetNumber:nil];
}

#pragma mark * Country Alert

+ (NSDictionary *)countryAlertSettings
{
    return [self alertSettingsForType:CBAlertType_CountryAlert
                         withLocation:nil
                         nextLocation:nil
                         carnetNumber:nil];
}

#pragma mark - Private

+ (NSDictionary *)alertSettingsForType:(CBAlertType)aType
                          withLocation:(NSString *)aLocation
                          nextLocation:(NSString *)aNextLocation
                          carnetNumber:(NSString *)aCarnetNumber
{
    NSString *retString = [CBAlertsManager textForAlertWithType:aType];
	NSNumber *priority = nil;
	NSNumber *occuranceType = nil;
    switch (aType) {
        case CBSimpleAlertType_Popup_WillYouBeTravellingSoon: {
            retString = [NSString stringWithFormat:@"Will you be travelling soon with carnet %@.", aCarnetNumber];
			priority = @1;
			occuranceType = @(CBAlertOccuranceTypePopup);
        }
            break;
		case CBSimpleAlertType_Error_LowFoils: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"%@ is ran out of foils. Please contact our office at 800-282-2900 should you require additional ones.", aCarnetNumber];
            } else {
                retString = [NSString stringWithFormat:retString, aCarnetNumber];
            }

			priority = @1;
			occuranceType = @(CBAlertOccuranceType_Regular);
		}
			break;
        case CBSimpleAlertType_Error_Expiring: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Carnet is expired! Please contact our office at 800-282-2900 if your travels extend past the expiration date."];
            }
            
			priority = @1;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
		case CBSimpleAlertType_Warning_Expiring: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Carnet will expire soon! Please contact our office at 800-282-2900  if your travels extend past the expiration date."];
            }
            
			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
		}
			break;
        case CBSimpleAlertType_Warning_LowFoils: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"%@ is running low on foils. Please contact our office at 800-282-2900 should you require additional ones.", aCarnetNumber];
            } else {
                retString = [NSString stringWithFormat:retString, aCarnetNumber];
            }

			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBSimpleAlertType_Warning_Signed: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Has this carnet been signed by the holder?"];
            }
            
			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBSimpleAlertType_Warning_Verify: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Please verify that this information is correct. If you have any questions please call our office at 800-282-2900."];
            }
            
			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBLocationAlertType_Reconstitute: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Some items from Carnet %@ were left in this country. Would you like to add these items back into the Carnet?", aCarnetNumber];
            } else {
                retString = [NSString stringWithFormat:retString, aCarnetNumber];
            }

			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBLocationAlertType_Validation_US: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Has this carnet been validated by US Customs?"];
            }
            
			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBLocationAlertType_Remove_USA: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Are you sure you want to remove %@?", aCarnetNumber];
            } else {
                retString = [NSString stringWithFormat:retString, aCarnetNumber];
            }

			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBLocationAlertType_Scan: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Please scan %@ for verification.", aCarnetNumber];
            } else {
                retString = [NSString stringWithFormat:retString, aCarnetNumber];
            }

			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBLocationAlertType_Stamp: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Please remember to get your Carnet(s) stamped before departing %@.", aLocation];
            } else {
                retString = [NSString stringWithFormat:retString, aLocation];
            }

			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBLocationAlertType_Validation: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Welcome to %@.  Please remember to validate this (all) carnet(s) with local customs.", aLocation];
            } else {
                retString = [NSString stringWithFormat:retString, aLocation];
            }

			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBLocationAlertType_Accompany: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Will this Carnet also accompany you on your upcoming trip to %@?", aNextLocation];
            } else {
                retString = [NSString stringWithFormat:retString, aNextLocation];
            }

			priority = @1;
			occuranceType = @(CBAlertOccuranceTypePopup);
        }
            break;
        case CBLocationAlertType_Travelling_All_Items: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"Will you be traveling with all items on %@?", aCarnetNumber];
            } else {
                retString = [NSString stringWithFormat:retString, aCarnetNumber];
            }

			priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBLocationAlertType_Wrong_Country: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"%@ was not an expected country of visit. Would you like to scan a carnet?", aLocation];
            } else {
                retString = [NSString stringWithFormat:retString, aLocation];
            }

			priority = @1;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBLocationAlertType_UnknowError: {
            if (!retString.length) {
                retString = [NSString stringWithFormat:@"There was a problem with this carnet in the country of %@. Please scan this QR Code by tapping the button below now or contact us at +1-800-422-4222", aLocation];
            } else {
                retString = [NSString stringWithFormat:retString, aLocation];
            }

            priority = @0;
			occuranceType = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBAlertType_AiportAlert: {
            retString       = @"";
            priority        = @0;
            occuranceType   = @(CBAlertOccuranceType_Regular);
        }
            break;
        case CBAlertType_CountryAlert: {
            retString       = @"";
            priority        = @0;
            occuranceType   = @(CBAlertOccuranceType_Regular);
        }
            break;
    }
    return  @{  keyCBAlertsSettingsUtilText             : retString,
                keyCBAlertsSettingsUtilPriority         : priority,
                keyCBAlertsSettingsUtilOccuranceType    : occuranceType,
                keyCBAlertsSettingsUtilButtons          : [CBAlertsSettingsUtil buttonsForType:aType]
                };
}

+ (NSArray *)buttonsForType:(CBAlertType)aType
{
    switch (aType) {
        case CBLocationAlertType_Travelling_All_Items: {
            return @[@(CBAlertButtonType_NO),@(CBAlertButtonType_TakeAll)];
        }
            break;
        case CBLocationAlertType_Reconstitute: {
            return @[@(CBAlertButtonType_NO), @(CBAlertButtonType_Reconstitute)];
        }
            break;
        case CBLocationAlertType_Remove_USA: {
            return @[@(CBAlertButtonType_NO), @(CBAlertButtonType_YES)];
        }
            break;
        case CBLocationAlertType_Validation:
        case CBLocationAlertType_Validation_US:
        case CBLocationAlertType_Stamp: {
            return @[@(CBAlertButtonType_Dismiss)];
        }
            break;
        case CBLocationAlertType_UnknowError:
        case CBLocationAlertType_Scan:
        case CBLocationAlertType_Wrong_Country: {
            return @[@(CBAlertButtonType_Scan)];
        }
		case CBLocationAlertType_Accompany:
            return @[@(CBAlertButtonType_NO), @(CBAlertButtonType_YES)];
            break;
        case CBSimpleAlertType_Warning_Verify:
            return @[@(CBAlertButtonType_Reject), @(CBAlertButtonType_Accept)];
            break;
        case CBSimpleAlertType_Popup_WillYouBeTravellingSoon:
            return @[@(CBAlertButtonType_NO),@(CBAlertButtonType_YES)];
            break;
        default:
            return @[@(CBAlertButtonType_Dismiss)];
            break;
    }
}

@end

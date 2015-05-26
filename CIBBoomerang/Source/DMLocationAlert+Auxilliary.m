//
//  DMLocationAlert+Auxilliary.m
//  CIBBoomerang
//
//  Created by Roma on 6/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMLocationAlert+Auxilliary.h"

#import <objc/runtime.h>

#import "CBAlertsSettingsUtil.h"
#import "DMManager.h"

NSString *const DMLocationAlertShownKey     = @"shown";
NSString *const DMLocationAlertPriority     = @"alertPriority";
NSString *const DMLocationAlertShowingDate  = @"showingDate";
NSString *const DMLocationAlertType         = @"type";
NSString *const DMLocationAlertOccurence    = @"alertOccuranceType";

@implementation DMLocationAlert (Auxilliary)

static char keySettingsDictionary;

+ (DMLocationAlert *)obtainLocationAlert:(CBAlertType)type forWaypoint:(DMWaypoint *)waypoint
{
    DMLocationAlert *alertObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                              inManagedObjectContext:[DMManager managedObjectContext]];
    
    alertObj.waypoint = waypoint;
    alertObj.type = type;
	return alertObj;
}

+ (DMLocationAlert *)obtainLocationAlertWithType:(CBAlertType)aType
{
    DMLocationAlert *alertObj   = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                              inManagedObjectContext:[DMManager managedObjectContext]];
    alertObj.type               = aType;
    return alertObj;
}

- (void)attachAlertPreferences
{
    if (objc_getAssociatedObject(self, &keySettingsDictionary) == nil) {
        NSString *country = [self.waypoint.carnet nextCountryNameForWaypoint:self.waypoint];
        objc_setAssociatedObject(self,
                                 &keySettingsDictionary,
                                 [CBAlertsSettingsUtil locationAlertSettings:self.type
                                                                    location:self.waypoint.country.name
                                                                nextLocation:country
                                                                carnetNumber:self.waypoint.carnet.identifier],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSString *)alertText
{
    return  objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilText];
}

- (NSArray *)alertButtons
{
    return objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilButtons];
}

- (NSInteger)alertPriority
{
    return [objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilPriority] integerValue];
}

- (NSInteger)alertOccuranceType
{
    return [objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilOccuranceType] integerValue];
}

- (NSInteger)alertType
{
    return self.type;
}

- (NSDictionary *)parametrs
{
    return @{
             DMLocationAlertShowingDate : [@(self.showingDate) copy],
             DMLocationAlertType        : [@(self.type) copy],
             DMLocationAlertShownKey    : [@(self.shown) copy]
             };
}

+ (id)alertFromParametrs:(NSDictionary *)aParametrs
{
    CBAlertType type        = [aParametrs[DMLocationAlertType] integerValue];
    DMLocationAlert *alert  = [DMLocationAlert obtainLocationAlertWithType:type];
    alert.shown             = [aParametrs[DMLocationAlertShowingDate] boolValue];
    alert.showingDate       = [aParametrs[DMLocationAlertShowingDate] doubleValue];
    return alert;
}

@end

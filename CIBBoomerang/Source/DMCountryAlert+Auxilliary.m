//
//  DMCountryAlert+Auxilliary.m
//  CIBBoomerang
//
//  Created by Roma on 9/3/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMCountryAlert+Auxilliary.h"

#import <objc/runtime.h>

#import "CBAlertsSettingsUtil.h"
#import "DMManager.h"


@implementation DMCountryAlert (Auxilliary)

static char keySettingsDictionary;

- (void)attachAlertPreferences
{
    if (objc_getAssociatedObject(self, &keySettingsDictionary) == nil) {
        objc_setAssociatedObject(self,
                                 &keySettingsDictionary,
                                 [CBAlertsSettingsUtil countryAlertSettings],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSString *)alertText
{
    return  self.text;
}

- (NSArray *)alertButtons
{
    return objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilButtons];
}

- (NSInteger)alertPriority
{
    return [objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilPriority] integerValue];
}

- (NSInteger)alertType
{
    return CBAlertType_CountryAlert;
}

- (NSInteger)alertOccuranceType
{
    return [objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilOccuranceType] integerValue];
}

+ (instancetype)newCountryAlert
{
    DMCountryAlert *countryAlert =  [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                                  inManagedObjectContext:[DMManager managedObjectContext]];
    return countryAlert;
}

@end

//
//  DMSimpleAlert+Auxilliary.m
//  CIBBoomerang
//
//  Created by Roma on 6/20/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMSimpleAlert+Auxilliary.h"

#import <objc/runtime.h>

#import "DMManager.h"
#import "CBAlertsSettingsUtil.h"

NSString *const keyDMSimpleAlertShow            = @"shown";
NSString *const keyDMSimpleAlertOccuranceType   = @"alertOccuranceType";
NSString *const DMSimpleAlertType               = @"alertType";

@implementation DMSimpleAlert (Auxilliary)

static char keySettingsDictionary;

- (void)attachAlertPreferences
{
    if (objc_getAssociatedObject(self, &keySettingsDictionary) == nil) {
        objc_setAssociatedObject(self,
                                 &keySettingsDictionary,
                                 [CBAlertsSettingsUtil simpleAlertSettings:self.type carnetIdentifier:self.carnet.identifier],
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

- (NSInteger)alertType
{
    return self.type;
}

- (NSInteger)alertOccuranceType
{
    return [objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilOccuranceType] integerValue];
}

+ (instancetype)obtainNewSimpleAlertWithType:(CBAlertType)aType
{
    DMSimpleAlert *alertObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                            inManagedObjectContext:[DMManager managedObjectContext]];
    alertObj.type = aType;
    return alertObj;
}

@end

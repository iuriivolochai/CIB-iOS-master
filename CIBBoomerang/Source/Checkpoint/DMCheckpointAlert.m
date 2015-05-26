#import "DMCheckpointAlert.h"

#import <objc/runtime.h>

#import "CBAlertsSettingsUtil.h"
#import "DMManager.h"


@interface DMCheckpointAlert ()
//@property (strong) NSArray *alertButtons;
@property (assign) NSUInteger alertPriority;
@property (assign) NSUInteger alertType;
@property (assign) NSUInteger alertOccuranceType;

@end


@implementation DMCheckpointAlert

@synthesize alertOccuranceType, alertPriority, alertType;

static char keySettingsDictionary;

- (void)attachAlertPreferences
{
    if (objc_getAssociatedObject(self, &keySettingsDictionary) == nil) {
        objc_setAssociatedObject(self,
                                 &keySettingsDictionary,
                                 [CBAlertsSettingsUtil aiportAlertSettings],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSString *)alertText
{
    return  self.text;
}

- (NSArray *)alertButtons
{
    return @[@(CBAlertButtonType_Dismiss)];
    //return objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilButtons];
}
/*
- (NSUInteger)alertPriority
{
    return [objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilPriority] integerValue];
}

- (NSUInteger)alertType
{
    return CBAlertType_AiportAlert;
}

- (NSUInteger)alertOccuranceType
{
    return [objc_getAssociatedObject(self, &keySettingsDictionary) [keyCBAlertsSettingsUtilOccuranceType] integerValue];
}*/

+ (instancetype)newAirportAlert
{
    DMCheckpointAlert *alert = [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                                             inManagedObjectContext:[DMManager managedObjectContext]];
    return alert;
}

@end

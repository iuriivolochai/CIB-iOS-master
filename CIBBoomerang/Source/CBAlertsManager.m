//
//  CBAlertsManager.m
//  CIBBoomerang
//
//  Created by Roma on 9/3/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBAlertsManager.h"
#import "DMManager.h"
#import "DDLog.h"

NSString *const kAlertKeyPrefix             = @"iphone.";
NSString *const kAlertPlistFileName         = @"alerts";
NSString *const kAlertPlistFileExtension    = @"plist";

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface CBAlertsManager ()

+ (NSString *)plistPath;

@end

@implementation CBAlertsManager

static NSDictionary *alerts = nil;

#pragma mark - Public

+ (void)updateAlertsPlist
{
    [DMManager loadAlertsWithCompletionHandler:^(NSDictionary *alertsDic, BOOL isErrorOccurred) {
        [self updateAlertsPlistFromDictionary:alertsDic isErrorOccurred:isErrorOccurred];
     }];
}

+ (void)updateAlertsPlistFromDictionary:(NSDictionary *)alertsDic isErrorOccurred:(BOOL)isErrorOccurred
{
    if (!isErrorOccurred) {
        NSMutableDictionary *newAlerts = [NSMutableDictionary dictionary];
        
        [alertsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *object, BOOL *stop) {
            NSString *finalKey = [self alertTypeForKey:key];
            [newAlerts setObject:object forKey:finalKey];
        }];
        
        [self saveAlertsWithDictionary:newAlerts];
        alerts = newAlerts;
    }
}

+ (NSString *)textForAlertWithType:(CBAlertType)aType
{
    NSString *text = alerts[[self keyForAlertType:aType]];
    return (text ? text : @"");
}

#pragma mark - Private

+ (void)initialize
{
    NSFileManager *manager  = [NSFileManager defaultManager];
    NSString *filePath      = [self plistPath];

    if ([manager fileExistsAtPath:filePath isDirectory:NULL]) {
        alerts = [NSDictionary dictionaryWithContentsOfFile:filePath];
    } else {
        alerts = @{};
    }
}

+ (void)saveAlertsWithDictionary:(NSDictionary *)newAlerts
{
    NSString *error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:newAlerts
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    
    if  (plistData) {
        [plistData writeToFile:[self plistPath] atomically:YES];
    } else {
        DDLogVerbose(@"saveAlertsWithDictionary: %@", error);
    }
}

+ (NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

+ (NSString *)plistPath
{
    static NSString *plistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *docsDirectory = [self documentsPath];
        NSString *fileNamePath  = [docsDirectory stringByAppendingPathComponent:kAlertPlistFileName];
        plistPath = [fileNamePath stringByAppendingPathExtension:kAlertPlistFileExtension];
    });
    
    return plistPath;
}

+ (NSString *)keyForAlertType:(CBAlertType)alertType
{
    return [NSString stringWithFormat:@"%d", alertType];
}

+ (NSString *)alertTypeForKey:(NSString *)aKey
{
    NSString *typeString = [aKey stringByReplacingOccurrencesOfString:kAlertKeyPrefix withString:@""];
    return typeString;
}

@end

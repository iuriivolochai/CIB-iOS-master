//
//  CBRequestStorage.m
//  CIBBoomerang
//
//  Created by Roma on 7/24/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBRequestStorage.h"
#import "NSData+AES.h"
#import "CBServerLoggingUtils.h"
#import "CBGateway.h"
#import "DDLog.h"


NSString *const CBRequestStoragePath_Carnet         = @"Carnet";
NSString *const CBRequestStoragePath_Logs           = @"Logs";
NSString *const CBRequestStoragePath_Instructions   = @"Instructions";
NSString *const CBRequestStoragePath_Alerts         = @"Texts";

NSString *const kStorageCarnetGUIDDefault           = @"Default";

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation CBRequestStorage

+ (void)saveRequestParameters:(NSDictionary *)parameters withPath:(NSString *)aPath method:(NSString *)aMethod carnetWithGUID:(NSString *)aGUID
{
    NSString *methodDirectoryPath   = [self methodDirectoryPathForPath:aPath method:aMethod carnetWithGUID:aGUID];
    
    if (![self createDirectoriesPathIfDoesntExistWithPath:methodDirectoryPath]) {
        return;
    }
    
    NSData *requestData = [self encryptedDataFromParameters:parameters];
    [requestData writeToFile:[self requestFilePathWithDirectoryPath:methodDirectoryPath] atomically:NO];
}

+ (NSData *)encryptedDataFromParameters:(NSDictionary *)parameters
{
    NSData *data  = [NSKeyedArchiver archivedDataWithRootObject:parameters];
    [data encryptWithString:[CBServerLoggingUtils deviceId]];
    return data;
}

+ (NSString *)requestFilePathWithDirectoryPath:(NSString *)directoryPath
{
    return [directoryPath stringByAppendingPathComponent:[NSProcessInfo processInfo].globallyUniqueString];
}

+ (NSString *)methodDirectoryPathForPath:(NSString *)aPath method:(NSString *)aMethod carnetWithGUID:(NSString *)aGUID
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:aGUID];
    NSString *targetDirectoryPath = [directoryPath stringByAppendingPathComponent:aPath];
    NSString *methodDirectoryPath = [targetDirectoryPath stringByAppendingPathComponent:aMethod];
    
    return methodDirectoryPath;
}

// returns: YES - path exists, NO - path doesn't exist
+ (BOOL)createDirectoriesPathIfDoesntExistWithPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDirectory = NO;
    NSError *error;
    if ([manager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (!isDirectory) {
            [manager removeItemAtPath:path error:&error];
            [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        }
    } else {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (error)  {
        DDLogError(@"%@", error.description);
        return NO;
    }
    
    return YES;
}

+ (NSArray *)fetchAndDeleteRequestsParametersForPath:(NSString *)aPath method:(NSString *)aMethod carnetGUID:(NSString *)aGUID
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory    = [paths objectAtIndex:0];
    NSString *directoryPath         = [documentsDirectory stringByAppendingPathComponent:aGUID];
    NSString *targetDirectoryPath   = [directoryPath stringByAppendingPathComponent:aPath];
    NSString *methodDirectoryPath   = [targetDirectoryPath stringByAppendingPathComponent:aMethod];

    NSError *error;
    NSArray *files = [manager contentsOfDirectoryAtPath:methodDirectoryPath error:&error];
    
    if (error) {
        return nil;
    }
    
    NSMutableArray *retArray;
    if (files.count) {
        retArray = [[NSMutableArray alloc] initWithCapacity:files.count];
        for (NSString *fileName in files) {
            NSString *filePath      = [methodDirectoryPath stringByAppendingPathComponent:fileName];
            NSData *encryptedData   = [NSData dataWithContentsOfFile:filePath];
            [encryptedData encryptWithString:[CBServerLoggingUtils deviceId]];
            NSDictionary *reqDict   = [NSKeyedUnarchiver unarchiveObjectWithData:encryptedData];
            [manager removeItemAtPath:filePath error:&error];
            [retArray addObject:reqDict];
        }
        [manager removeItemAtPath:methodDirectoryPath error:&error];
    }
    
    if (error) {
        DDLogError(@"%@", error.description);
        return nil;
    }
    
    return retArray;
}

+ (void)saveLogRequestWithParametrs:(NSDictionary *)aParametrs forCarnetWithGUID:(NSString *)aGUID
{
    if (!aGUID) {
        return;
    }
    NSDictionary *dicWithGUID = @{  aGUID : aParametrs  };
    [self saveRequestParameters:dicWithGUID
                         withPath:CBRequestStoragePath_Logs
                           method:GATEWAY_REQUEST_METHOD_POST
                   carnetWithGUID:kStorageCarnetGUIDDefault];
    
}

+ (NSArray *)fetchAndDeleteLogRequests
{
    return [self fetchAndDeleteRequestsParametersForPath:CBRequestStoragePath_Logs
                                                  method:GATEWAY_REQUEST_METHOD_POST
                                              carnetGUID:kStorageCarnetGUIDDefault];
}

@end

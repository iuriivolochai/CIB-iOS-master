//
//  CBRequestStorage.h
//  CIBBoomerang
//
//  Created by Roma on 7/24/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBRequestStorage : NSObject

FOUNDATION_EXPORT NSString *const CBRequestStoragePath_Alerts;
FOUNDATION_EXPORT NSString *const CBRequestStoragePath_Carnet;
FOUNDATION_EXPORT NSString *const CBRequestStoragePath_Instructions;
FOUNDATION_EXPORT NSString *const CBRequestStoragePath_Logs;

+ (void)saveRequestParameters:(NSDictionary *)parameters withPath:(NSString *)path method:(NSString *)aMethod carnetWithGUID:(NSString *)aGUID;
+ (NSArray *)fetchAndDeleteRequestsParametersForPath:(NSString *)aPath method:(NSString *)aMethod carnetGUID:(NSString *)aGUID;

+ (void)saveLogRequestWithParametrs:(NSDictionary *)aParametrs forCarnetWithGUID:(NSString *)aGUID;
+ (NSArray *)fetchAndDeleteLogRequests;

@end

//
//  CBGateway.m
//  CIBBoomerang
//
//  Created by Roma on 5/23/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBGateway.h"

#define GATEWAY_HEADER_VALUE                @"application/json"
#define GATEWAY_HEADER_KEY                  @"Accept"

#define GATEWAY_ROOT_PATH                   @"https://ws.atacarnet.com"
#define GATEWAY_CARNETS_PATH                @"/carnets"
#define GATEWAY_INSTRUCTIONS_PATH           @"/instructions/"
#define GATEWAY_INSTRUCTIONS_TYPE_AIRPORT   @"%@?type="
#define GATEWAY_INSTRUCTIONS_TYPE_COUNTRY   @"%@?type=country"
#define GATEWAY_LOGS_PATH                   @"/logs"
#define GATEWAY_TEXT_PATH                   @"/texts?device=iphone"
#define GATEWAY_LOCATIONS_PATH              @"/locations"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#ifdef DEBUG
#   define GatewayLog(fmt, ...) DDLogError((@"Error! No %@ provided in %s [Line %d]"), fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define Gateway(fmt,...) 
#endif

#ifdef DEBUG
#   define GatewayKeysLogger(fmt, ...) DDLogError((@"Error! No value provided for key %@ in %s [Line %d]"), fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif

@implementation CBGateway

#pragma mark - Public
#pragma mark - GET 

+ (void)sendGETRequestForAirportInstructionsWithAirportID:(NSString *)airportID
                                          completionBlock:(ConnectionCompletionBlock)completionHandler
                                             errorHandler:(ConnectionErrorBlock)errorHandler
{
#if DEBUG
    if (!airportID) {
        GatewayLog(@"airportID");
        return;
    }
#endif
    
    NSString *directoryPath = [GATEWAY_ROOT_PATH stringByAppendingString:GATEWAY_INSTRUCTIONS_PATH];
    NSString *resourcePath = [directoryPath stringByAppendingFormat:GATEWAY_INSTRUCTIONS_TYPE_AIRPORT, airportID];
    
    NSMutableURLRequest *request = [CBGateway composeRequestWithMethod:GATEWAY_REQUEST_METHOD_GET
                                                               forPath:resourcePath
                                                         withParametrs:nil];
    
    [CBConnectionManager sendAsynchronousRequest:request completionHandler:completionHandler errorHandler:errorHandler];
}

+ (void)sendGETRequestForCarnetWithGUID:(NSString *)GUID
                        completionBlock:(ConnectionCompletionBlock)completionHandler
                             errorBlock:(ConnectionErrorBlock)errorHandler
{
#if DEBUG
    if (!GUID) {
        GatewayLog(@"GUID");
        return;
    }
#endif
    
    NSString *directoryPath = [GATEWAY_ROOT_PATH stringByAppendingString:GATEWAY_CARNETS_PATH];
    NSString *resourcePath = [directoryPath stringByAppendingPathComponent:GUID];

    NSMutableURLRequest *request = [CBGateway composeRequestWithMethod:GATEWAY_REQUEST_METHOD_GET
                                                               forPath:resourcePath
                                                         withParametrs:nil];
    
    [CBConnectionManager sendAsynchronousRequest:request completionHandler:completionHandler errorHandler:errorHandler];
}

+ (void)sendGETRequestForCountryInstructionsWithCountryISOCode:(NSString *)ISOCode
                                               completionBlock:(ConnectionCompletionBlock)completionHandler
                                                  errorHandler:(ConnectionErrorBlock)errorHandler
{
#if DEBUG
    if (!ISOCode) {
        GatewayLog(@"ISOCode");
        return;
    }
#endif
    
    NSString *directoryPath = [GATEWAY_ROOT_PATH stringByAppendingString:GATEWAY_INSTRUCTIONS_PATH];
    NSString *resourcePath = [directoryPath stringByAppendingFormat:GATEWAY_INSTRUCTIONS_TYPE_COUNTRY, ISOCode];
    
    NSMutableURLRequest *request = [CBGateway composeRequestWithMethod:GATEWAY_REQUEST_METHOD_GET
                                                               forPath:resourcePath
                                                         withParametrs:nil];
    
    [CBConnectionManager sendAsynchronousRequest:request completionHandler:completionHandler errorHandler:errorHandler];

}

+ (void)sendGETRequestForAlertsWithParametrs:(NSDictionary *)parametrs
                             completionBlock:(ConnectionCompletionBlock)compeltionBlock
                                  errorBlock:(ConnectionErrorBlock)errorBlock
{
    NSString *resourcePath          = [GATEWAY_ROOT_PATH stringByAppendingString:GATEWAY_TEXT_PATH];
    NSMutableURLRequest *request    = [CBGateway composeRequestWithMethod:GATEWAY_REQUEST_METHOD_GET
                                                               forPath:resourcePath
                                                         withParametrs:nil];
    [CBConnectionManager sendAsynchronousRequest:request completionHandler:compeltionBlock errorHandler:errorBlock];
}

#pragma mark - POST

#if DEBUG
#   define LOGGING_KEYS @[@"CarnetGuid", @"Action", @"Latitude", @"Longitude", @"Date", @"DeviceId", @"Data", @"Timezone", @"CountryId"]
#endif

+ (void)sendLOGRequestForCarnetWithGUID:(NSString *)GUID
                        loggingParamets:(NSDictionary *)loggingParametrs
                        completionBlock:(ConnectionCompletionBlock)completionHandler
                             errorBlock:(ConnectionErrorBlock)errorHandler
{
#if DEBUG
//    if (!GUID) {
//        GatewayLog(@"GUID");
//        return;
//    }
    
    for (NSDictionary *loggingDic in loggingParametrs[@"Logs"]) {
        for (NSString *key in LOGGING_KEYS) {
            id obj = [loggingDic objectForKey:key];
            if (!obj)
                GatewayKeysLogger(key);
        }
    }
#endif
    
    NSString *directoryPath = [GATEWAY_ROOT_PATH stringByAppendingString:GATEWAY_LOGS_PATH];

    NSMutableURLRequest *request = [CBGateway composeRequestWithMethod:GATEWAY_REQUEST_METHOD_POST
                                                               forPath:directoryPath
                                                         withParametrs:loggingParametrs];
    
    [CBConnectionManager sendAsynchronousRequest:request completionHandler:completionHandler errorHandler:errorHandler];
}

#pragma mark - PATCH

#if DEBUG
#   define UPDATE_KEYS @[@"Timestamp"]
#endif

+ (void)sendUPDATERequestForCarnetWithGUID:(NSString *)GUID
                           updateParametrs:(NSDictionary *)parameters
                           completionBlock:(ConnectionCompletionBlock)completionHandler
                                errorBlock:(ConnectionErrorBlock)errorHandler
{
#if DEBUG
    if (!GUID) {
        GatewayLog(@"GUID");
        return;
    }
    
    for (NSString *key in UPDATE_KEYS) {
        id obj = [parameters objectForKey:key];
        if (!obj)
            GatewayKeysLogger(key);
    }
#endif
    
    NSString *directoryPath = [GATEWAY_ROOT_PATH stringByAppendingString:GATEWAY_CARNETS_PATH];
    NSString *resourcePath = [directoryPath stringByAppendingPathComponent:GUID];
    
    NSMutableURLRequest *request = [CBGateway composeRequestWithMethod:GATEWAY_REQUEST_METHOD_PATCH
                                                               forPath:resourcePath
                                                         withParametrs:parameters];
    
    [CBConnectionManager sendAsynchronousRequest:request completionHandler:completionHandler errorHandler:errorHandler];

}

#pragma mark - DELETE
+ (void)sendDELETERequestForCarnetWithGUID:(NSString *)GUID
                           completionBlock:(ConnectionCompletionBlock)completionHandler
                                errorBlock:(ConnectionErrorBlock)errorHandler
{
#if DEBUG
    if (!GUID) {
        GatewayLog(@"GUID");
        errorHandler (nil);
        return;
    }
#endif
    
    NSString *directoryPath = [GATEWAY_ROOT_PATH stringByAppendingString:GATEWAY_CARNETS_PATH];
    NSString *resourcePath  = [directoryPath stringByAppendingPathComponent:GUID];
#if DEBUG
    NSString *finalPath     = [resourcePath stringByAppendingString:@"?debug=true"];
#else
    NSString *finalPath     = [resourcePath stringByAppendingString:@"?debug=false"];
#endif

    
    
    NSMutableURLRequest *request = [CBGateway composeRequestWithMethod:GATEWAY_REQUEST_METHOD_DELETE
                                                               forPath:finalPath
                                                         withParametrs:nil];
    
    [CBConnectionManager sendAsynchronousRequest:request completionHandler:completionHandler errorHandler:errorHandler];
}

+ (void)sendGETRequestForLocationsWithCompletionBlock:(ConnectionCompletionBlock)completionHandler errorBlock:(ConnectionErrorBlock)errorHandler
{
    NSString *directoryPath = [GATEWAY_ROOT_PATH stringByAppendingString:GATEWAY_LOCATIONS_PATH];
    
    NSMutableURLRequest *request = [CBGateway composeRequestWithMethod:GATEWAY_REQUEST_METHOD_GET
                                                               forPath:directoryPath
                                                         withParametrs:nil];
    
    [CBConnectionManager sendAsynchronousRequest:request completionHandler:completionHandler errorHandler:errorHandler];
}
                                                    

#pragma mark - Private

+ (NSMutableURLRequest *)composeRequestWithMethod:(NSString *)requestMethod forPath:(NSString *)path withParametrs:(NSDictionary *)parametrs
{
    NSURL *anURL = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:anURL];
    [request setHTTPMethod:requestMethod];
    [request setValue:GATEWAY_HEADER_VALUE forHTTPHeaderField:GATEWAY_HEADER_KEY];
    [request setValue:GATEWAY_HEADER_VALUE forHTTPHeaderField:@"Content-Type"];
    
    if (parametrs) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parametrs
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
        
        if (!jsonData) {
            DDLogError(@"Got an error: %@", error);
        }
        
        [request setHTTPBody:jsonData];
    }
    return request;
}

+ (void)sendTestRequestToServerWithCompletionBlock:(ConnectionCompletionBlock)completionHandler errorBlock:(ConnectionErrorBlock)errorHandler
{
    NSString *directoryPath = [GATEWAY_ROOT_PATH stringByAppendingString:GATEWAY_CARNETS_PATH];
    
    NSMutableURLRequest *request = [CBGateway composeRequestWithMethod:GATEWAY_REQUEST_METHOD_GET
                                                               forPath:directoryPath
                                                         withParametrs:nil];
    
    [CBConnectionManager sendAsynchronousRequest:request completionHandler:completionHandler errorHandler:errorHandler];
}

@end

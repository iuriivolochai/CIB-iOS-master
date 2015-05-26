//
//  CBGateway.h
//  CIBBoomerang
//
//  Created by Roma on 5/23/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBConnectionManager.h"

#define GATEWAY_REQUEST_METHOD_DELETE       @"DELETE"
#define GATEWAY_REQUEST_METHOD_GET          @"GET"
#define GATEWAY_REQUEST_METHOD_PATCH        @"PATCH"
#define GATEWAY_REQUEST_METHOD_POST         @"POST"

@interface CBGateway : NSObject

/*
Sends GET request for carnet with GUID
    GUID (Globally Unique Identifier) must not be nil
    completionBlock and errorBlock are optional, but strictly recommended
 */
+ (void)sendGETRequestForCarnetWithGUID:(NSString *)GUID
                        completionBlock:(ConnectionCompletionBlock)completionHandler
                             errorBlock:(ConnectionErrorBlock)errorHandler;


/*    
 Sends GET request for airport instructions for airport identifier
    airportID must not be nil
    completionBlock and errorBlock are optional, but strictly recommended
 */
+ (void)sendGETRequestForAirportInstructionsWithAirportID:(NSString *)airportID
                                          completionBlock:(ConnectionCompletionBlock)completionHandler
                                             errorHandler:(ConnectionErrorBlock)errorHandler;


/*
 Sends GET request for country instructions for country ISO Code
    ISO Code must not be nil
    completionBlock and errorBlock are optional, but strictly recommended
 */
+ (void)sendGETRequestForCountryInstructionsWithCountryISOCode:(NSString *)ISOCode
                                               completionBlock:(ConnectionCompletionBlock)completionHandler
                                                  errorHandler:(ConnectionErrorBlock)errorHandler;

/*
 Sends DELETE request for carnet with GUID
    GUID (Globally Unique Identifier) must not be nil
    completionBlock and errorBlock are optional, but strictly recommended
 */
+ (void)sendDELETERequestForCarnetWithGUID:(NSString *)GUID
                           completionBlock:(ConnectionCompletionBlock)completionHandler
                                errorBlock:(ConnectionErrorBlock)errorHandler;


/*
 Sends POST request for carnet with GUID
    GUID (Globally Unique Identifier) must not be nil
    loggingParametrs must not be nil
    completionBlock and errorBlock are optional, but strictly recommended
 */
+ (void)sendLOGRequestForCarnetWithGUID:(NSString *)GUID
                        loggingParamets:(NSDictionary *)loggingParametrs
                        completionBlock:(ConnectionCompletionBlock)completionHandler
                             errorBlock:(ConnectionErrorBlock)errorHandler;


/*
 Sends UPDATE request for carnet with GUID
    GUID (Globally Unique Identifier) must not be nil
    parametrs dictionary must not be nil
    completionBlock and errorBlock are optional, but strictly recommended
 */
+ (void)sendUPDATERequestForCarnetWithGUID:(NSString *)GUID
                           updateParametrs:(NSDictionary *)parameters
                           completionBlock:(ConnectionCompletionBlock)completionHandler
                                errorBlock:(ConnectionErrorBlock)errorHandler;

//TODO:
/*
 Sends GET request for Alerts  of different kind
 */
+ (void)sendGETRequestForAlertsWithParametrs:(NSDictionary *)parametrs
                             completionBlock:(ConnectionCompletionBlock)completionBlock
                                  errorBlock:(ConnectionErrorBlock)errorBlock;

+ (void)sendGETRequestForLocationsWithCompletionBlock:(ConnectionCompletionBlock)completionHandler errorBlock:(ConnectionErrorBlock)errorHandler;

+ (void)sendTestRequestToServerWithCompletionBlock:(ConnectionCompletionBlock)completionHandler errorBlock:(ConnectionErrorBlock)errorHandler;

@end

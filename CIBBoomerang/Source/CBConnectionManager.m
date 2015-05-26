//
//  CBConnectionManager.m
//
//  Created by Roman Kopaliani on 28.02.13.
//  Copyright (c) 2013 Roman. All rights reserved.
//

#import "CBConnectionManager.h"

#import <objc/runtime.h>

#define CONNECTION_RESPONSE_KEY         @"CONNECTION_RESPONSE_KEY"
#define CONNECTION_RESPONSE_STATUS      @"CONNECTION_RESPONSE_STATUS"
#define CONNECTION_RECIEVED_DATA_KEY    @"CONNECTION_RECIEVED_DATA_KEY"
#define CONNECTION_ERROR_BLOCK          @"CONNECTION_ERROR_BLOCK"
#define CONNECTION_COMPLETE_BLOCK       @"CONNECTION_COMPLETE_BLOCK"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface CBConnectionManager() <NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableArray *activeConnections;

@end


@implementation CBConnectionManager

#pragma mark - Initiliazation

- (id)init
{
    self = [super init];
    if (self) {
        _activeConnections = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

+ (CBConnectionManager *)sharedManager
{
    static dispatch_once_t once;
    static CBConnectionManager *instance;
    dispatch_once(&once, ^ {
        instance = [[CBConnectionManager alloc] init];
    });
    return instance;
}


#pragma mark - Public Functions

+ (void)sendAsynchronousRequest:(NSURLRequest *)request completionHandler:(ConnectionCompletionBlock)completionHandler errorHandler:(ConnectionErrorBlock)errorHandler;
{
    [[CBConnectionManager sharedManager] sendAsynchronousRequest:request completionHandler:completionHandler errorHandler:errorHandler];
}

+ (void)stopAllConnections
{
    [[CBConnectionManager sharedManager] stopAllConnections];
}

+ (void)stopConnectionWithRequest:(NSURLRequest *)request
{
    CBConnectionManager *manager = [CBConnectionManager sharedManager];
    [manager.activeConnections enumerateObjectsUsingBlock:^(NSURLConnection *connection, NSUInteger idx, BOOL *stop) {
        if (request == connection.originalRequest) {
            [manager stopConnection:connection];
            *stop = YES;
        }
    }];
}

#pragma mark - Private Function

- (void)startConnection:(NSURLConnection *)connection
{
    [_activeConnections addObject:connection];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [connection start];
}

- (void)stopConnection:(NSURLConnection *)connection
{
    [connection cancel];
    
    objc_setAssociatedObject(connection, CONNECTION_RECIEVED_DATA_KEY,  nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(connection, CONNECTION_COMPLETE_BLOCK,     nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(connection, CONNECTION_ERROR_BLOCK,        nil, OBJC_ASSOCIATION_RETAIN);
    
    [_activeConnections removeObject:connection];
    connection = nil;
    
    if ([_activeConnections count] == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
}

- (void)stopAllConnections
{
    [_activeConnections makeObjectsPerformSelector:@selector(cancel)];
    for (NSURLConnection *connection in _activeConnections) {
        [self stopConnection:connection];
    }
}

- (void)sendAsynchronousRequest:(NSURLRequest *)request
              completionHandler:(ConnectionCompletionBlock)completionHandler
                   errorHandler:(ConnectionErrorBlock)errorHandler;
{
    if (request == nil) {
        return;
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:NO];
    
    if (completionHandler) {
        objc_setAssociatedObject(connection, CONNECTION_COMPLETE_BLOCK, completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    if (errorHandler) {
        objc_setAssociatedObject(connection, CONNECTION_ERROR_BLOCK, errorHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

    [self startConnection:connection];
    
    DDLogVerbose(@"%@", [[request URL] absoluteString]);
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
    objc_setAssociatedObject(connection, CONNECTION_RESPONSE_KEY, response, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(connection, CONNECTION_RECIEVED_DATA_KEY,[NSMutableData new], OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(connection, CONNECTION_RESPONSE_STATUS, [NSNumber numberWithInt:httpResponse.statusCode], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableData *responseData = (NSMutableData *)objc_getAssociatedObject(connection, CONNECTION_RECIEVED_DATA_KEY);
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    ConnectionErrorBlock block = objc_getAssociatedObject(connection, CONNECTION_ERROR_BLOCK);
    if (block != nil) {
        block(error);
    }
    [self stopConnection:connection];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ConnectionErrorBlock block = objc_getAssociatedObject(connection, CONNECTION_ERROR_BLOCK);
    NSMutableData *responseData = (NSMutableData *)objc_getAssociatedObject(connection, CONNECTION_RECIEVED_DATA_KEY);
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)objc_getAssociatedObject(connection, CONNECTION_RESPONSE_KEY);
    int statusCode = [(NSNumber *)objc_getAssociatedObject(connection, CONNECTION_RESPONSE_STATUS) integerValue];
    NSError *error = nil;
    
    NSDictionary *json = (responseData.length)  ? [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error]
                                                : nil;
    switch (statusCode) {
        case CBConnectionManagerResponseStatusSucess: {
            ConnectionCompletionBlock block = objc_getAssociatedObject(connection, CONNECTION_COMPLETE_BLOCK);
            if (block != nil) {
                block(json);
            }
        }
            break;
        case CBConnectionManagerResponseStatusUpdated: {
            NSString *timestamp = [httpResponse allHeaderFields][@"Timestamp"];
            ConnectionCompletionBlock block = objc_getAssociatedObject(connection, CONNECTION_COMPLETE_BLOCK);
            if (block != nil) {
                block(timestamp);
            }
        }
            break;
        case CBConnectionManagerResponseStatusNoCarnet: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(@"No Carnet Found", nil)};
            NSError *noCarnetError = [[NSError alloc] initWithDomain:CONNECTION_MANAGER_DOMAIN code:statusCode userInfo:userInfo];
            if (block)
                block (noCarnetError);
        }
            break;
        case CBConnectionManagerResponseStatusConflict: {
            NSDictionary *reqDict = @{NSLocalizedRecoverySuggestionErrorKey : connection.originalRequest};
            NSError *conflictError = [[NSError alloc] initWithDomain:CONNECTION_MANAGER_DOMAIN
                                                                code:statusCode
                                                            userInfo:reqDict];
            if (block)
                block (conflictError);
        }
            break;
        case CBConnectionManagerResponseStatusAlreadyTracked: {
            NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : @"This Carnet is being tracked on another device" };
            NSError *trackedError   = [[NSError alloc] initWithDomain:CONNECTION_MANAGER_DOMAIN
                                                               code:statusCode
                                                           userInfo:errorDict];
            if (block)
                block (trackedError);
        }
            break;
        case CBConnectionManagerResponseStatusError: {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : (json)   ? json[@"Message"]
                                       : NSLocalizedString(@"Server error occurred. Please check your connection and try again later.", nil)};
            NSError *error = [[NSError alloc] initWithDomain:CONNECTION_MANAGER_DOMAIN
                                                        code:statusCode
                                                    userInfo:userInfo];
            if (block)
                block (error);
        }
            break;
        case CBConnectionManagerResponseStatusInvalidRequest: {
            NSDictionary *userInfo = nil;
            
//            if (json) {
//                userInfo = @{NSLocalizedDescriptionKey : json[@"Message"]};
                userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Carnet not enabled for use with this app. Please contact our office at 800-282-2900 for more details.", nil)};
//            }
            
            NSError *error = [[NSError alloc] initWithDomain:CONNECTION_MANAGER_DOMAIN code:statusCode userInfo:userInfo];
            if (block) block (error);
        }
            break;
        default: {
            if (error) {
                if (block != nil) {
                    block(error);
                }
            }
            if ([json valueForKey:@"error"]) {
                // Check for Error response
                NSDictionary *errorDictionary = [json valueForKey:@"error"];
                NSInteger code = [[errorDictionary valueForKey:@"code"] integerValue];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString([errorDictionary valueForKey:@"description"], nil)};
                NSError *error = [[NSError alloc] initWithDomain:CONNECTION_MANAGER_DOMAIN code:code userInfo:userInfo];
                [self connection:connection didFailWithError:error];
            }
        }
            break;
    }
    [self stopConnection:connection];
}

#if ACTIVE_SERVER_PROVIDES_CERTIFICATE && DEBUG

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSArray * trustedHosts = @[CONNECTION_MANAGER_DOMAIN];
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([trustedHosts containsObject:challenge.protectionSpace.host])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#endif

@end

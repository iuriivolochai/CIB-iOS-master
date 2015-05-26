//
//  CBConnectionManager.m
//
//  Created by Roman Kopaliani on 28.02.13.
//  Copyright (c) 2013 Roman. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef void (^ConnectionCompletionBlock)(id obj);
typedef void (^ConnectionErrorBlock)(NSError *error);

@interface CBConnectionManager : NSObject

// Sends asynchronous request, provides completion handlers blocks for success response, error handling block for responce with error
+ (void)sendAsynchronousRequest:(NSURLRequest *)request
              completionHandler:(ConnectionCompletionBlock)completionHandler
                   errorHandler:(ConnectionErrorBlock)errorHandler;

// Stops all active connections, the method should be invoked on DidRecieveMemoryWarning
+ (void)stopAllConnections;

// Stops connection for a  given request
+ (void)stopConnectionWithRequest:(NSURLRequest *)request;

@end

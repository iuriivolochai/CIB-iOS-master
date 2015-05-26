//
//  CBReachabilityObserver.h
//  CIBBoomerang
//
//  Created by Roma on 5/27/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

FOUNDATION_EXPORT NSString *const CBReachabilityObserverNetworkStatusDidChange;

@interface CBReachabilityObserver : NSObject

+ (void)startObserving;
+ (NetworkStatus)networkStatus;
+ (BOOL)anyConnectionAvailable;
+ (BOOL)wifiConnectionAvailable;

@end

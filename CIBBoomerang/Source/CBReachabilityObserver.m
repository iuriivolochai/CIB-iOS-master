//
//  CBReachabilityObserver.m
//  CIBBoomerang
//
//  Created by Roma on 5/27/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBReachabilityObserver.h"


NSString *const CBReachabilityObserverNetworkStatusDidChange = @"CBReachabilityObserverNetworkStatusDidChange";

@interface CBReachabilityObserver ()

@property (strong, nonatomic) Reachability *reachability;

@end

@implementation CBReachabilityObserver

+ (void)startObserving
{
    [CBReachabilityObserver sharedObserver];
}

+ (CBReachabilityObserver *)sharedObserver
{
    static dispatch_once_t once;
    static CBReachabilityObserver *instance;
    dispatch_once(&once, ^ {
        instance = [[CBReachabilityObserver alloc] init];
    });
    return instance;
}

- (id)init
{
	self = [super init];
    if (self) {
        [self setUpReachability];
    }
    return self;
}

#pragma mark - Public

+ (NetworkStatus)networkStatus
{
    return [[CBReachabilityObserver sharedObserver] reachabilityStatus];
}

+ (BOOL)anyConnectionAvailable
{
    BOOL reachable = ([[CBReachabilityObserver sharedObserver] reachabilityStatus] == ReachableViaWiFi) || ([[CBReachabilityObserver sharedObserver] reachabilityStatus] == ReachableViaWWAN);
    return reachable;
}

+ (BOOL)wifiConnectionAvailable
{
    BOOL reachableViaWiFi = ([[CBReachabilityObserver sharedObserver] reachabilityStatus] == ReachableViaWiFi);
    return reachableViaWiFi;
}

#pragma mark - Set Up

- (void)setUpReachability
{
    _reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [_reachability startNotifier];
}

#pragma mark - Private

- (NetworkStatus)reachabilityStatus
{
    return self.reachability.currentReachabilityStatus;
}

#pragma mark - SCNetworkReachabilityDelegate

- (void)reachabilityChanged:(id)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CBReachabilityObserverNetworkStatusDidChange object:nil];
    });
}

@end

//
//  CBAppDelegate.m
//  CIBBoomerang
//
//  Created by Roma on 4/23/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBAppDelegate.h"
#import "CBAppearance.h"
#import "DMManager.h"
#import "CBNotificationsManager.h"
#import "CBReachabilityObserver.h"
#import "CBSettings.h"
#import "CBAlertsManager.h"
#import "CBStoryboardUtil.h"

#import "LIOLookIOManager.h"
#import "TestFlight.h"
#import "lelib.h"
#import <CrashReporter/CrashReporter.h>
#import "CBLogentriesLog.h"
#import "CBLogentriesFormatter.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#if DEBUG
    #import "CBAlertsManager.h"
#endif

#define PRELOAD_CARNETS 0
#define LOGENTRIES_API_KEY @"b5e8b525-4af6-42d9-b1b0-a23b710b953d"
#define LOGENTRIES_ACCOUNT_KEY @"5719c7a3-e25e-4641-9206-da6d8003ef81"
#define LOGENTRIES_HOST_KEY @"ios Host"
#define LOGENTRIES_LOG_KEY @"f69a64ee-df15-49db-9c61-b091cf978bed"

@implementation CBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // enables shake motion
    application.applicationSupportsShakeToEdit = YES;
    
    // app main color
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        application.keyWindow.tintColor = [UIColor colorWithRed:0.09f green:0.27f blue:0.62f alpha:1];
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
#endif
    
    LELog* log = [LELog sharedInstance];
    log.token = LOGENTRIES_API_KEY;
    
    CBLogentriesLog *logentriesLogger = [[CBLogentriesLog alloc] init];
    logentriesLogger.leLog = log;
    [logentriesLogger setLogFormatter:[[CBLogentriesFormatter alloc] init]];
    [DDLog addLogger:logentriesLogger];
    
    [CBAppearance customizeAppearance];

    [DMManager preloadCountries];
    
    [CBReachabilityObserver startObserving];
    
    [DMManager loadLocations];
    [DMManager cleanDublicates];
	
    [TestFlight takeOff:@"4e25f1b5-0240-4337-83df-8f7ad6cdb98a"];
    
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    
    // Check if we previously crashed
    /*if ([crashReporter hasPendingCrashReport]) {
        [self handleCrashReport];
    }
    
    // Enable the Crash Reporter
    if (![crashReporter enableCrashReporterAndReturnError: &error]) {
        DDLogWarn(@"Warning: Could not enable crash reporter: %@", error);
    }*/
    
#ifdef DEBUG
	[CBNotificationsManager deleteAll];
    #if (PRELOAD_CARNETS)
        [DMManager preloadCarnets];
    #endif
#endif
    
    [CBAlertsManager updateAlertsPlist];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[CBStoryboardUtil createMainStoryboard] instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    [[LIOLookIOManager sharedLookIOManager] performSetupWithDelegate:nil];
    DDLogVerbose(@"Application did finish launching");
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[DMManager switchToBackgroundMode];
    
//    [CBNotificationsManager scheduleNotificationForCarnet:nil withType:CBNotificationsManagerNotificationTypeLocation withFireDate:nil];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[DMManager switchToForegroundMode];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    [CBNotificationsManager handleLocalNotification:notification];
}

- (void)handleCrashReport {
    DDLogVerbose(@"App has crashed on last run, loading crash report...");
    
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
    
    // Try loading the crash report
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData == nil) {
        DDLogError(@"Could not load crash report: %@", error);
        [crashReporter purgePendingCrashReport];
        return;
    }
    
    // We could send the report from here, but we'll just print out
    // some debugging info instead
    PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error] ;
    if (report == nil) {
        DDLogError(@"Could not parse crash report");
        [crashReporter purgePendingCrashReport];
        return;
    }
    
    // convert crash report to human readable text (which can be converted then to symbolicated output with symbolicatecrash script
    // and app.dSYM file)
    NSString *humanReadable = [PLCrashReportTextFormatter stringValueForCrashReport:report withTextFormat:PLCrashReportTextFormatiOS];
    [[LELog sharedInstance] log:humanReadable];
    
    // Purge the report
    [crashReporter purgePendingCrashReport];
    return;
}

@end

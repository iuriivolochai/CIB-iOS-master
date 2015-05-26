//
//  CBBaseViewController.m
//  CIBBoomerang
//
//  Created by Roma on 8/22/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBBaseViewController.h"

@interface CBBaseViewController ()

@end

@implementation CBBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self subscribeToRefreshNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self unsubscribeToRefreshNotifications];
}

- (void)subscribeToRefreshNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:DMNotificationTypeTravellingStateRefreshed object:nil];
}

- (void)unsubscribeToRefreshNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DMNotificationTypeTravellingStateRefreshed object:nil];
}

- (void)refreshView
{
    NSLog(@"To be subclassed");
}

- (void)handleManagerAction:(DMManagerAlertHandlingAction)anAction
{
    switch (anAction) {
        case DMManagerAlertHandlingAction_PopController:
            [self popViewController];
            break;
        case DMManagerAlertHandlingAction_Scan:
            [self showScanViewController];
            break;
        case DMManagerAlertHandlingAction_ShowReminderPicker:
            [self showReminderPicker];
            break;
        case DMManagerAlertHandlingAction_ShowTravelDetailsScreen:
            [self showTravelDetailsScreen];
            break;
        case DMManagerAlertHandlingAction_ShowPopoverAlerts:
            [self showPopoverAlerts];
            break;
        default:
            break;
    }
}

- (void)logUnsuccessfulScanIfNeededWithError:(NSError *)error carnetGUID:(NSString *)guid
{
    if (error) {
        if ((error.code == CBConnectionManagerResponseStatusInvalidRequest) || (error.code == CBConnectionManagerResponseStatusAlreadyTracked)) {
            [DMManager logServerAction:DMLoggedActionTypeUnsuccessfulScan withComments:@"Unsuccessful scan" forCarnetGUID:guid];
        }
    }
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showScanViewController
{
    if ([self class] == [CBBaseViewController class]) {
        [self doesNotRecognizeSelector:_cmd];
    }
}

- (void)showReminderPicker
{
    if ([self class] == [CBBaseViewController class]) {
        [self doesNotRecognizeSelector:_cmd];
    }
}

- (void)showTravelDetailsScreen
{
    if ([self class] == [CBBaseViewController class]) {
        [self doesNotRecognizeSelector:_cmd];
    }
}

- (void)showCarnetDetailsScreenWithCarnet:(DMCarnet *)aCarnet;
{
    if ([self class] == [CBBaseViewController class]) {
        [self doesNotRecognizeSelector:_cmd];
    }
}

- (void)showPopoverAlerts
{
    
}

@end

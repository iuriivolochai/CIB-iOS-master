//
//  CBBaseViewController.h
//  CIBBoomerang
//
//  Created by Roma on 8/22/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMManager.h"

@interface CBBaseViewController : UIViewController

- (void)handleManagerAction:(DMManagerAlertHandlingAction)anAction;

@end

@interface CBBaseViewController (MethodsToOverride)

- (void)showCarnetDetailsScreenWithCarnet:(DMCarnet *)aCarnet;
- (void)showPopoverAlerts;
- (void)showReminderPicker;
- (void)showScanViewController;
- (void)showTravelDetailsScreen;
- (void)logUnsuccessfulScanIfNeededWithError:(NSError *)error carnetGUID:(NSString *)guid;

@end

//
//  CBScannerViewController.h
//  CIBBoomerang
//
//  Created by Roma on 4/23/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBBaseViewController.h"

FOUNDATION_EXPORT NSString * const ScannerViewControllerStoryboardId;

@class CBScannerViewController;
@protocol CBScannerViewControllerDelegate <NSObject>

- (void)scannerViewController:(CBScannerViewController *)controller didCancelScannigManually:(BOOL)manually withError:(NSError *)error;
- (void)scannerViewController:(CBScannerViewController *)controller didRecognizeQRCodeWithString:(NSString *)code;

@end

@interface CBScannerViewController : CBBaseViewController

@property (weak, nonatomic) id <CBScannerViewControllerDelegate> delegate;

@end

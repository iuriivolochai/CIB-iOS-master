//
//  UIAlertView+BlockCallback.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 5/3/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "UIAlertView+BlockCallback.h"
#import <objc/runtime.h>

#pragma mark - 
#pragma mark - CBAlertViewHandler

@interface CBAlertViewHandler : NSObject <UIAlertViewDelegate>

@end

@implementation CBAlertViewHandler

static NSString *const keyAlertViewCompletionHandler = @"keyAlertViewCompletionHandler";

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    CBAlertViewDidDismissWithButtonIndex completion = objc_getAssociatedObject(alertView, &keyAlertViewCompletionHandler);
    
    if (completion) {
        completion(alertView, buttonIndex);
    }
}

@end

#pragma mark -
#pragma mark - UIAlertView (BlockCallback)

@implementation UIAlertView (BlockCallback)

static CBAlertViewHandler *alertViewHandler = nil;

+ (CBAlertViewHandler *)alertViewHandler {
    if (alertViewHandler == nil) {
        @synchronized ([UIAlertView class]) {
            if (alertViewHandler == nil) {
                alertViewHandler = [[CBAlertViewHandler alloc] init];
            }
        }
    }
    
    return alertViewHandler;
}


+ (UIAlertView *)alertWithTitle:(NSString *)title
                        message:(NSString *)message
              cancelButtonTitle:(NSString *)cancelButtonTitle
               otherButtonTitles:(NSArray *)otherButtonTitles
                     completion:(CBAlertViewDidDismissWithButtonIndex)completion
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:[self alertViewHandler] cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    for (NSString *buttonTitle in otherButtonTitles) {
        [alertView addButtonWithTitle:buttonTitle];
    }
    
    objc_setAssociatedObject(alertView, &keyAlertViewCompletionHandler, completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return alertView;
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
          otherButtonTitles:(NSArray *)otherButtonTitles
                completion:(CBAlertViewDidDismissWithButtonIndex)completion
{
    UIAlertView *alertView = [self alertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles completion:completion];
    [alertView show];
}

@end

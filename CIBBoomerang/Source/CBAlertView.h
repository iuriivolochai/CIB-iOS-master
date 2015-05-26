//
//  CBAlertView.h
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 5/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBAlertView;

typedef void (^CBAlertViewCompletionHandler) (CBAlertView *sender, NSUInteger buttonIndex);

@interface CBAlertView : UIView

+ (void)showAlertViewWithTitle:(NSString *)title
                       message:(NSString *)message
			 cancelButtonTitle:(NSString *)cancelTitle
			 otherButtonTitles:(NSArray *)otherButtonTitles
					completion:(CBAlertViewCompletionHandler)comletion;

+ (NSUInteger)cancelButtonIndex;

@end

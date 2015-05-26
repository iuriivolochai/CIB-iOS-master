//
//  UIAlertView+BlockCallback.h
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 5/3/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

typedef void (^CBAlertViewDidDismissWithButtonIndex)(UIAlertView *sender, NSInteger buttonIndex);

@interface UIAlertView (BlockCallback)

+ (UIAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(CBAlertViewDidDismissWithButtonIndex)completion;

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(CBAlertViewDidDismissWithButtonIndex)completion;

@end

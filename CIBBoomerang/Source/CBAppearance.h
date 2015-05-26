//
//  DCAppearance.h
//  PwC
//
//  Created by Roman on 2/26/13.
//  Copyright (c) 2013 Roman. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SEGUE_SHOW_HELP @"Show Help Controller"

typedef NS_ENUM(int16_t, CBAppearanceButtonType) {
    CBAppearanceButtonTypeNone = 0,
    CBAppearanceButtonTypeBack,
    CBAppearanceButtonTypeHelp,
    CBAppearanceButtonTypeSettings
};

@interface CBAppearance : NSObject

+ (void)customizeAppearance;
+ (void)customizeViewController:(UIViewController *)controller
                      withTitle:(NSString *)title
           leftBarBarButtonType:(CBAppearanceButtonType)left
             rightBarButtonType:(CBAppearanceButtonType)right;

@end

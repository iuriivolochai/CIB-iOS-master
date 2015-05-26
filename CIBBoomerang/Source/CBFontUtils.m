//
//  CBFontUtils.m
//  CIBBoomerang
//
//  Created by Roma on 6/6/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBFontUtils.h"

@implementation CBFontUtils

+ (UIFont *)droidSansFontBold:(BOOL)bold ofSize:(CGFloat)size
{
    NSString *fontName  = (bold) ? @"DroidSans-Bold" : @"DroidSans";
    UIFont *font        = [UIFont fontWithName:fontName size:size];
    return font;
}

@end

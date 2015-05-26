//
//  CBStoryboardUtil.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 10/18/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBStoryboardUtil.h"

@implementation CBStoryboardUtil

+ (UIStoryboard *)createMainStoryboard
{
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        return [UIStoryboard storyboardWithName:[self mainStoryboardNameForIOS7AndAbove] bundle:nil];
    } else {
        return [UIStoryboard storyboardWithName:[self mainStoryboardNameForIOSBelow7] bundle:nil];
    }
}

+ (NSString *)mainStoryboardNameForIOSBelow7
{
    return @"MainStoryboard";
}

+ (NSString *)mainStoryboardNameForIOS7AndAbove
{
    return @"MainStoryboard_ios7";
}

+ (UIStoryboard *)createFakeLocationStoryboard
{
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        return [UIStoryboard storyboardWithName:[self fakeLocationStoryboardNameForIOS7AndAbove] bundle:nil];
    } else {
        return [UIStoryboard storyboardWithName:[self fakeLocationStoryboardNameForIOSBelow7] bundle:nil];
    }
}

+ (NSString *)fakeLocationStoryboardNameForIOSBelow7
{
    return @"FakeLocationStoryboard";
}

+ (NSString *)fakeLocationStoryboardNameForIOS7AndAbove
{
    return @"FakeLocationStoryboard_ios7";
}

@end

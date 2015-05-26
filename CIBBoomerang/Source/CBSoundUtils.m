//
//  CBSoundUtils.m
//  CIBBoomerang
//
//  Created by Roma on 6/13/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBSoundUtils.h"
#import "CBSettings.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation CBSoundUtils

+ (void)playSound:(CBSystemSoundType)soundType
{
    if ((soundType != CBSystemSoundTypeNone) && [CBSettings soundsOn]) {
        AudioServicesPlaySystemSound(soundType);
    }
}

@end

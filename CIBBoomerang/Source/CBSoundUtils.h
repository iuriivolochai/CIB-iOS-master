//
//  CBSoundUtils.h
//  CIBBoomerang
//
//  Created by Roma on 6/13/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(int16_t, CBSystemSoundType){
    CBSystemSoundTypeNone = 0,
    CBSystemSoundTypeTick = 1057,
    CBSystemSoundTypeError = 1073,
    CBSystemSoundTypeWarning = 1306,
    
    CBSystemSoundTypeChatMessageSent = 1004,
    CBSystemSoundTypeChatMessageReceived = 1003,
    CBSystemSoundTypeAlertShow = 1057,
    CBSystemSoundTypeAlertHide = CBSystemSoundTypeNone,
    CBSystemSoundTypeAlertPress = 1104,
};

@interface CBSoundUtils : NSObject

+ (void)playSound:(CBSystemSoundType)soundType;

@end

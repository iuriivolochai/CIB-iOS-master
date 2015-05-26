//
//  CBAlertObjectProtocol.h
//  CIBBoomerang
//
//  Created by Roma on 6/13/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CBAlertObjectProtocol <NSObject>

@optional

- (NSString *)alertText;
- (NSArray *)alertButtons;
- (NSUInteger)alertPriority;
- (NSUInteger)alertType;
- (NSUInteger)alertOccuranceType;

- (NSDictionary *)parametrs;
+ (id)alertFromParametrs:(NSDictionary *)aParametrs;

- (void)attachAlertPreferences;

@end

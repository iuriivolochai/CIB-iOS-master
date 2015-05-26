//
//  CBRegion.h
//  CIBBoomerang
//
//  Created by Roma on 8/5/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLRegion;
@interface CBRegion : NSObject

@property (strong, nonatomic, readonly) CLRegion  *region;
@property (strong, nonatomic, readonly) NSDate    *enterDate;

+ (instancetype)regionWithCLRegion:(CLRegion *)region enterDate:(NSDate *)date;

@end

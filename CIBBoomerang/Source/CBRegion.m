//
//  CBRegion.m
//  CIBBoomerang
//
//  Created by Roma on 8/5/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBRegion.h"


@interface CBRegion ()

@property (strong, nonatomic, readwrite) CLRegion  *region;
@property (strong, nonatomic, readwrite) NSDate    *enterDate;

@end

@implementation CBRegion

+ (instancetype)regionWithCLRegion:(CLRegion *)region enterDate:(NSDate *)date
{
    return [[self alloc] initWithCLRegion:region enterDate:date];
}

- (id)initWithCLRegion:(CLRegion *)region enterDate:(NSDate *)enterDate
{
    self = [super init];
    if (self) {
        self.region     = region;
        self.enterDate  = enterDate;
    }
    return self;
}

@end

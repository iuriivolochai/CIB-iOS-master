//
//  DMWaypoint.m
//  CIBBoomerang
//
//  Created by Roma on 8/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMWaypoint.h"
#import "DMCarnet.h"
#import "DMCountry.h"
#import "DMItem.h"
#import "DMLocationAlert.h"

#define CONTAINS_STARTPOINT_ISSUE_MASK      256

@implementation DMWaypoint

@dynamic dateArrival;
@dynamic dateDeparture;
@dynamic kind;
@dynamic status;
@dynamic containsError;
@dynamic activeForCarnet;
@dynamic alerts;
@dynamic carnet;
@dynamic country;
@dynamic items;

- (BOOL)containsStartpointIssue
{
    return (self.kind & CONTAINS_STARTPOINT_ISSUE_MASK) > 0;
}

- (void)setContainsStartpointIssue:(BOOL)flag
{
    if (flag) {
        self.kind |= CONTAINS_STARTPOINT_ISSUE_MASK;
    } else {
        self.kind ^= CONTAINS_STARTPOINT_ISSUE_MASK;
    }
}

@end

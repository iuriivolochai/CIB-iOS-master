//
//  DMCarnet.m
//  CIBBoomerang
//
//  Created by Roma on 7/24/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMCarnet.h"
#import "DMItem.h"
#import "DMSimpleAlert.h"
#import "DMWaypoint.h"


@implementation DMCarnet

@dynamic accountNumber;
@dynamic carnetStatus;
@dynamic dateExpired;
@dynamic dateIssued;
@dynamic flagActive;
@dynamic flagVerified;
@dynamic foilsBlue;
@dynamic foilsWhite;
@dynamic foilsYellow;
@dynamic guid;
@dynamic identifier;
@dynamic issuedBy;
@dynamic timestamp;
@dynamic activeWaypoint;
@dynamic alerts;
@dynamic items;
@dynamic waypoints;
@dynamic trackedByDeviceId;

@synthesize createOnDevice=_createOnDevice;

@end

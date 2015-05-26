//
//  DMLocationAlert.h
//  CIBBoomerang
//
//  Created by Roma on 6/20/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DMWaypoint;

@interface DMLocationAlert : NSManagedObject

@property (nonatomic) NSTimeInterval showingDate;
@property (nonatomic) BOOL shown;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) DMWaypoint *waypoint;

@end

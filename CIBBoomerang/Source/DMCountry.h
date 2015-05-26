//
//  DMCountry.h
//  CIBBoomerang
//
//  Created by Roma on 9/3/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CBLocation.h"

@class DMCheckpoint, DMCountryAlert, DMWaypoint;

@interface DMCountry : NSManagedObject <CBLocation>

@property (nonatomic) int16_t code;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) BOOL supportsCarnet;
@property (nonatomic, retain) NSSet *checkpoints;
@property (nonatomic, retain) NSSet *waypoints;
@property (nonatomic, retain) DMCountryAlert *alert;
@end

@interface DMCountry (CoreDataGeneratedAccessors)

- (void)addCheckpointsObject:(DMCheckpoint *)value;
- (void)removeCheckpointsObject:(DMCheckpoint *)value;
- (void)addAirports:(NSSet *)values;
- (void)removeAirports:(NSSet *)values;

- (void)addWaypointsObject:(DMWaypoint *)value;
- (void)removeWaypointsObject:(DMWaypoint *)value;
- (void)addWaypoints:(NSSet *)values;
- (void)removeWaypoints:(NSSet *)values;

@end

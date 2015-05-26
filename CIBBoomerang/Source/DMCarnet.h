//
//  DMCarnet.h
//  CIBBoomerang
//
//  Created by Roma on 7/24/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DMItem, DMSimpleAlert, DMWaypoint;

@interface DMCarnet : NSManagedObject

@property (nonatomic, retain) NSString * accountNumber;
@property (nonatomic) int16_t carnetStatus;
@property (nonatomic) NSTimeInterval dateExpired;
@property (nonatomic) NSTimeInterval dateIssued;
@property (nonatomic) BOOL flagActive;
@property (nonatomic) BOOL flagVerified;
@property (nonatomic) int16_t foilsBlue;
@property (nonatomic) int16_t foilsWhite;
@property (nonatomic) int16_t foilsYellow;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * issuedBy;
@property (nonatomic, retain) NSString * timestamp;
@property (nonatomic, retain) NSString * trackedByDeviceId;
@property (nonatomic, retain) DMWaypoint *activeWaypoint;
@property (nonatomic, retain) NSSet *alerts;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) NSOrderedSet *waypoints;

@property (retain) NSDate *createOnDevice;
@end

@interface DMCarnet (CoreDataGeneratedAccessors)

- (void)addAlertsObject:(DMSimpleAlert *)value;
- (void)removeAlertsObject:(DMSimpleAlert *)value;
- (void)addAlerts:(NSSet *)values;
- (void)removeAlerts:(NSSet *)values;

- (void)addItemsObject:(DMItem *)value;
- (void)removeItemsObject:(DMItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)insertObject:(DMWaypoint *)value inWaypointsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWaypointsAtIndex:(NSUInteger)idx;
- (void)insertWaypoints:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWaypointsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWaypointsAtIndex:(NSUInteger)idx withObject:(DMWaypoint *)value;
- (void)replaceWaypointsAtIndexes:(NSIndexSet *)indexes withWaypoints:(NSArray *)values;
- (void)addWaypointsObject:(DMWaypoint *)value;
- (void)removeWaypointsObject:(DMWaypoint *)value;
- (void)addWaypoints:(NSOrderedSet *)values;
- (void)removeWaypoints:(NSOrderedSet *)values;

@end

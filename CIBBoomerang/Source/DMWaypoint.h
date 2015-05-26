//
//  DMWaypoint.h
//  CIBBoomerang
//
//  Created by Roma on 8/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DMCarnet, DMCountry, DMItem, DMLocationAlert;

@interface DMWaypoint : NSManagedObject

@property (nonatomic) NSTimeInterval dateArrival;
@property (nonatomic) NSTimeInterval dateDeparture;
@property (nonatomic) int16_t kind;
@property (nonatomic) int16_t status;
@property (nonatomic) BOOL containsError;
@property (nonatomic, retain) DMCarnet *activeForCarnet;
@property (nonatomic, retain) NSSet *alerts;
@property (nonatomic, retain) DMCarnet *carnet;
@property (nonatomic, retain) DMCountry *country;
@property (nonatomic, retain) NSSet *items;

@property (nonatomic) BOOL containsStartpointIssue;

@end

@interface DMWaypoint (CoreDataGeneratedAccessors)

- (void)addAlertsObject:(DMLocationAlert *)value;
- (void)removeAlertsObject:(DMLocationAlert *)value;
- (void)addAlerts:(NSSet *)values;
- (void)removeAlerts:(NSSet *)values;

- (void)addItemsObject:(DMItem *)value;
- (void)removeItemsObject:(DMItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end

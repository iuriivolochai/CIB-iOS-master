//
//  DMItem.h
//  CIBBoomerang
//
//  Created by Roma on 5/15/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DMCarnet, DMWaypoint;

@interface DMItem : NSManagedObject

@property (nonatomic) int64_t globalIdentifier;
@property (nonatomic) int16_t identifier;
@property (nonatomic) int16_t quantity;
@property (nonatomic, retain) NSString * specification;
@property (nonatomic) float value;
@property (nonatomic) float weight;
@property (nonatomic) BOOL splitted;
@property (nonatomic, retain) DMCarnet *carnet;
@property (nonatomic, retain) DMWaypoint *waypoint;

@end

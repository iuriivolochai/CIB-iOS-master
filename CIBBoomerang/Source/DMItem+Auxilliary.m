//
//  DMItem+Auxilliary.m
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 4/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMItem+Auxilliary.h"
#import "DMCarnet+Auxilliary.h"
#import "DMManager.h"

NSString * const keyDMItemGlobalIdentifier = @"Id";
NSString * const keyDMItemIdentifier = @"ItemNo";
NSString * const keyDMItemSpecification = @"Description";
NSString * const keyDMItemQuantity = @"NoOfPieces";
NSString * const keyDMItemValue = @"Value";
NSString * const keyDMItemWaypoint = @"keyItemWaypoint";
NSString * const keyDMItemCountry = @"CountryId";
NSString * const keyDMItemWeight = @"Weight";

@implementation DMItem (Auxilliary)

#pragma mark - Crate Object

+ (DMItem *)newItemWithIdentifier:(int16_t)identifier
{
	DMItem *itemObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                    inManagedObjectContext:[DMManager managedObjectContext]];

	itemObj.identifier = identifier;
	return itemObj;
}

+ (DMItem *)newItemWithData:(NSDictionary *)itemData carnet:(DMCarnet *)carnet
{
	DMItem *itemObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
													inManagedObjectContext:[DMManager managedObjectContext]];
	itemObj.identifier = [itemData[keyDMItemIdentifier] integerValue];
    itemObj.globalIdentifier = [itemData[keyDMItemGlobalIdentifier] integerValue];
	itemObj.specification = itemData[keyDMItemSpecification];
	itemObj.quantity = [itemData[keyDMItemQuantity] integerValue];
	itemObj.weight = [itemData[keyDMItemWeight] floatValue];
	itemObj.value = [itemData[keyDMItemValue] floatValue];

    NSString *countryID = [itemData [keyDMItemCountry] isKindOfClass:[NSString class]] ? itemData[keyDMItemCountry] : nil;
    DMWaypoint *waypoint = nil;
    if (countryID)
        waypoint = [carnet obtainProcessedWaypointByCountryID:countryID];
    
    if (waypoint) {
        itemObj.waypoint = waypoint;
        itemObj.splitted = YES;
    }
    else {
        itemObj.waypoint = carnet.activeWaypoint;
    }
    
	return itemObj;
}

#pragma mark - Obtain Object

+ (DMItem *)itemForCarnet:(DMCarnet *)carnet withItemId:(NSString *)itemId
{
	__block	DMItem *managedObject = nil;
	[carnet.items enumerateObjectsUsingBlock:^(DMItem *item, BOOL *stop) {
		if (item.identifier == [itemId integerValue]) {
			managedObject = item;
			*stop = YES;
		}
	}];
    
    return managedObject;

}

@end

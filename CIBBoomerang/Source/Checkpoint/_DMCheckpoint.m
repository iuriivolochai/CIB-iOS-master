// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DMCheckpoint.m instead.

#import "_DMCheckpoint.h"

const struct DMCheckpointAttributes DMCheckpointAttributes = {
	.altitude = @"altitude",
	.ident = @"ident",
	.latitude = @"latitude",
	.location = @"location",
	.longitude = @"longitude",
	.name = @"name",
	.type = @"type",
};

const struct DMCheckpointRelationships DMCheckpointRelationships = {
	.alert = @"alert",
	.country = @"country",
};

const struct DMCheckpointFetchedProperties DMCheckpointFetchedProperties = {
};

@implementation DMCheckpointID
@end

@implementation _DMCheckpoint

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DMCheckpoint" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DMCheckpoint";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DMCheckpoint" inManagedObjectContext:moc_];
}

- (DMCheckpointID*)objectID {
	return (DMCheckpointID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"altitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"altitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic altitude;



- (int16_t)altitudeValue {
	NSNumber *result = [self altitude];
	return [result shortValue];
}

- (void)setAltitudeValue:(int16_t)value_ {
	[self setAltitude:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveAltitudeValue {
	NSNumber *result = [self primitiveAltitude];
	return [result shortValue];
}

- (void)setPrimitiveAltitudeValue:(int16_t)value_ {
	[self setPrimitiveAltitude:[NSNumber numberWithShort:value_]];
}





@dynamic ident;






@dynamic latitude;



- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}

- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic location;






@dynamic longitude;



- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic name;






@dynamic type;






@dynamic alert;

	

@dynamic country;

	






@end

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DMCheckpointAlert.m instead.

#import "_DMCheckpointAlert.h"

const struct DMCheckpointAlertAttributes DMCheckpointAlertAttributes = {
	.showingDate = @"showingDate",
	.shown = @"shown",
	.text = @"text",
};

const struct DMCheckpointAlertRelationships DMCheckpointAlertRelationships = {
	.checkpoint = @"checkpoint",
};

const struct DMCheckpointAlertFetchedProperties DMCheckpointAlertFetchedProperties = {
};

@implementation DMCheckpointAlertID
@end

@implementation _DMCheckpointAlert

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DMCheckpointAlert" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DMCheckpointAlert";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DMCheckpointAlert" inManagedObjectContext:moc_];
}

- (DMCheckpointAlertID*)objectID {
	return (DMCheckpointAlertID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"shownValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"shown"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic showingDate;






@dynamic shown;



- (BOOL)shownValue {
	NSNumber *result = [self shown];
	return [result boolValue];
}

- (void)setShownValue:(BOOL)value_ {
	[self setShown:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveShownValue {
	NSNumber *result = [self primitiveShown];
	return [result boolValue];
}

- (void)setPrimitiveShownValue:(BOOL)value_ {
	[self setPrimitiveShown:[NSNumber numberWithBool:value_]];
}





@dynamic text;






@dynamic checkpoint;

	






@end

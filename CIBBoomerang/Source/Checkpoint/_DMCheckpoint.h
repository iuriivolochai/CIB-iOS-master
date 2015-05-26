// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DMCheckpoint.h instead.

#import <CoreData/CoreData.h>


extern const struct DMCheckpointAttributes {
	__unsafe_unretained NSString *altitude;
	__unsafe_unretained NSString *ident;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *type;
} DMCheckpointAttributes;

extern const struct DMCheckpointRelationships {
	__unsafe_unretained NSString *alert;
	__unsafe_unretained NSString *country;
} DMCheckpointRelationships;

extern const struct DMCheckpointFetchedProperties {
} DMCheckpointFetchedProperties;

@class DMCheckpointAlert;
@class DMCountry;









@interface DMCheckpointID : NSManagedObjectID {}
@end

@interface _DMCheckpoint : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DMCheckpointID*)objectID;





@property (nonatomic, strong) NSNumber* altitude;



@property int16_t altitudeValue;
- (int16_t)altitudeValue;
- (void)setAltitudeValue:(int16_t)value_;

//- (BOOL)validateAltitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ident;



//- (BOOL)validateIdent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* latitude;



@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* location;



//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) DMCheckpointAlert *alert;

//- (BOOL)validateAlert:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) DMCountry *country;

//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;





@end

@interface _DMCheckpoint (CoreDataGeneratedAccessors)

@end

@interface _DMCheckpoint (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAltitude;
- (void)setPrimitiveAltitude:(NSNumber*)value;

- (int16_t)primitiveAltitudeValue;
- (void)setPrimitiveAltitudeValue:(int16_t)value_;




- (NSString*)primitiveIdent;
- (void)setPrimitiveIdent:(NSString*)value;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSString*)primitiveLocation;
- (void)setPrimitiveLocation:(NSString*)value;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;





- (DMCheckpointAlert*)primitiveAlert;
- (void)setPrimitiveAlert:(DMCheckpointAlert*)value;



- (DMCountry*)primitiveCountry;
- (void)setPrimitiveCountry:(DMCountry*)value;


@end

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DMCheckpointAlert.h instead.

#import <CoreData/CoreData.h>


extern const struct DMCheckpointAlertAttributes {
	__unsafe_unretained NSString *showingDate;
	__unsafe_unretained NSString *shown;
	__unsafe_unretained NSString *text;
} DMCheckpointAlertAttributes;

extern const struct DMCheckpointAlertRelationships {
	__unsafe_unretained NSString *checkpoint;
} DMCheckpointAlertRelationships;

extern const struct DMCheckpointAlertFetchedProperties {
} DMCheckpointAlertFetchedProperties;

@class DMCheckpoint;





@interface DMCheckpointAlertID : NSManagedObjectID {}
@end

@interface _DMCheckpointAlert : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DMCheckpointAlertID*)objectID;





@property (nonatomic, strong) NSDate* showingDate;



//- (BOOL)validateShowingDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* shown;



@property BOOL shownValue;
- (BOOL)shownValue;
- (void)setShownValue:(BOOL)value_;

//- (BOOL)validateShown:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* text;



//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) DMCheckpoint *checkpoint;

//- (BOOL)validateCheckpoint:(id*)value_ error:(NSError**)error_;





@end

@interface _DMCheckpointAlert (CoreDataGeneratedAccessors)

@end

@interface _DMCheckpointAlert (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveShowingDate;
- (void)setPrimitiveShowingDate:(NSDate*)value;




- (NSNumber*)primitiveShown;
- (void)setPrimitiveShown:(NSNumber*)value;

- (BOOL)primitiveShownValue;
- (void)setPrimitiveShownValue:(BOOL)value_;




- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;





- (DMCheckpoint*)primitiveCheckpoint;
- (void)setPrimitiveCheckpoint:(DMCheckpoint*)value;


@end

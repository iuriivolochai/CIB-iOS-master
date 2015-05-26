#import "_DMCheckpoint.h"
#import "CBLocation.h"

typedef NS_ENUM(NSInteger, DMCheckpointType){
    DMCheckpointTypeAirport,
    DMCheckpointTypePort,
    DMCheckpointTypeBorder
};

@interface DMCheckpoint : _DMCheckpoint <CBLocation> {} 

+ (DMCheckpoint*)insertOrRaplaceCheckpointWithId:(NSString*)ident inManagedObjectContext:(NSManagedObjectContext*)context;

+ (NSUInteger)count;
+ (void)retrieveNearestCheckpointsForLocationWithLatitude:(double)latitude
                                                longitude:(double)longitude
									    completionHandler:(void (^)(NSArray *checkpoints))completionHandler;
+ (NSArray *)checkpoints;
+ (NSArray *)airports;
+ (NSArray *)borders;
+ (NSArray *)ports;

+ (DMCheckpoint *)checkpointById:(NSString *)checkpointId;
+ (void)cleanDublicates;

- (DMCheckpointType)checkpointType;
- (BOOL)hasAlertToShow;
- (void)setAlertShown:(BOOL)shown;
- (void)refreshAlertState;


@end

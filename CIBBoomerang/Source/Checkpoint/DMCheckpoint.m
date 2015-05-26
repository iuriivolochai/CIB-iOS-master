#import "DMCheckpoint.h"
#import "DMManager.h"
#import "DMCheckpointAlert.h"

const int           _kNearestAirportsMAXCount = 6;
const double        _kLocationsDelta          = 3.5;
const NSUInteger    _keyDMCoordinateMAXValue = 200;

@interface DMCheckpoint ()

// Private interface goes here.

@end


@implementation DMCheckpoint

+ (DMCheckpoint*)insertOrRaplaceCheckpointWithId:(NSString*)ident inManagedObjectContext:(NSManagedObjectContext*)context
{
    DMCheckpoint *checkpoint = [self checkpointById:ident inManagedObjectContext:context];
    if (checkpoint == nil) {
        checkpoint = [self insertInManagedObjectContext:context];
        checkpoint.ident = ident;
    }
    return checkpoint;
}

+ (NSUInteger)count
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    [request setIncludesSubentities:NO];
    return [[DMManager managedObjectContext] countForFetchRequest:request error:nil];
}

+ (void)retrieveNearestCheckpointsForLocationWithLatitude:(double)latitude
                                                longitude:(double)longitude
									    completionHandler:(void (^)(NSArray *checkpoints))completionHandler
{
    NSManagedObjectContext *context     = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	NSManagedObjectContext *mainContext = [DMManager managedObjectContext];
	context.parentContext = mainContext;
    
	[context performBlock:^{
		NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
        
        NSNumber *maxLatitude   = @(latitude + _kLocationsDelta);
		NSNumber *minLatitude   = @(latitude - _kLocationsDelta);
		NSNumber *maxLongitude  = @(longitude + _kLocationsDelta);
		NSNumber *minLongitude  = @(longitude - _kLocationsDelta);
        
        CLLocation *location    = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
		fetchRequest.predicate  = [[NSCompoundPredicate alloc]
                                   initWithType:NSAndPredicateType
                                   subpredicates:@[  [self nonEmptyPredicate],
                                                     [self betweenPredicateForKeyPath:DMCheckpointAttributes.longitude forMinValue:minLongitude maxValue:maxLongitude],
                                                     [self betweenPredicateForKeyPath:DMCheckpointAttributes.latitude forMinValue:minLatitude maxValue:maxLatitude]]];
        
		fetchRequest.resultType         = NSDictionaryResultType;
        fetchRequest.propertiesToFetch  = @[[self managedObjectIDDescription], DMCheckpointAttributes.latitude, DMCheckpointAttributes.longitude];
		NSError *error                  = nil;
		NSArray *results                = [context executeFetchRequest:fetchRequest error:&error];
        if (!results.count) {
            completionHandler (nil);
            return;
        }
        
        NSArray *sortedResults          = [self sortedArray:results byDistanceFromLocation:location];
        NSRange sortingRange            = (sortedResults.count >= _kNearestAirportsMAXCount) ? NSMakeRange(0, _kNearestAirportsMAXCount)
        : NSMakeRange(0, sortedResults.count);
		NSArray *objectIDs              = [[sortedResults subarrayWithRange:sortingRange] valueForKey:@"objectId"];
        
		dispatch_async(dispatch_get_main_queue(), ^{
			NSFetchRequest *mainFetchRequest    = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
            mainFetchRequest.predicate          = [self predicateForObjectIDArray:objectIDs];
            fetchRequest.resultType = NSManagedObjectResultType;
            
			NSArray *airports = [mainContext executeFetchRequest:mainFetchRequest error:nil];
            
			if (completionHandler) {
				completionHandler([self sortedArray:airports byDistanceFromLocation:location]);
			}
		});
	}];
}

+ (NSArray *)sortedArray:(NSArray *)sourceArray byDistanceFromLocation:(CLLocation *)location
{
    NSArray *sortedResuts = [sourceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        double latitude1    = [[obj1 valueForKey:DMCheckpointAttributes.latitude] doubleValue];
        double latitude2    = [[obj2 valueForKey:DMCheckpointAttributes.latitude] doubleValue];
        
        double longitude1   = [[obj1 valueForKey:DMCheckpointAttributes.longitude] doubleValue];
        double longitude2   = [[obj2 valueForKey:DMCheckpointAttributes.longitude] doubleValue];
		
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:latitude1 longitude:longitude1];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:latitude2 longitude:longitude2];
        
        double dist1 = [location1 distanceFromLocation:location];
        double dist2 = [location2 distanceFromLocation:location];
        
        return (dist1 > dist2) ? NSOrderedDescending : NSOrderedAscending;
    }];
    return sortedResuts;
}


+ (NSPredicate *)nonEmptyPredicate
{
    /* latitude predicate */
    NSExpression    *latitudeLeftExpresstion =  [NSExpression expressionForKeyPath:DMCheckpointAttributes.latitude];
    NSExpression    *latitudeRigthExpression =  [NSExpression expressionForConstantValue:@(_keyDMCoordinateMAXValue)];
    NSPredicate     *latitudePredicate =        [NSComparisonPredicate predicateWithLeftExpression:latitudeLeftExpresstion
                                                                                   rightExpression:latitudeRigthExpression
                                                                                          modifier:NSDirectPredicateModifier
                                                                                              type:NSNotEqualToPredicateOperatorType
                                                                                           options:NSNormalizedPredicateOption];
    /* longitude predicate */
    NSExpression    *longitudeLeftExpresstion = [NSExpression expressionForKeyPath:DMCheckpointAttributes.longitude];
    NSExpression    *longitudeRigthExpression = [NSExpression expressionForConstantValue:@(_keyDMCoordinateMAXValue)];
    NSPredicate     *longitudePredicate =       [NSComparisonPredicate predicateWithLeftExpression:longitudeLeftExpresstion
                                                                                   rightExpression:longitudeRigthExpression
                                                                                          modifier:NSDirectPredicateModifier
                                                                                              type:NSNotEqualToPredicateOperatorType
                                                                                           options:NSNormalizedPredicateOption];
    
    NSPredicate     *retPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[latitudePredicate, longitudePredicate]];
    return retPredicate;
}

+ (NSPredicate *)betweenPredicateForKeyPath:(NSString *)keyPath forMinValue:(NSNumber *)minValue maxValue:(NSNumber *)maxValue
{
    NSExpression    *keyPathExpression  =   [NSExpression expressionForKeyPath:keyPath];
    NSExpression    *minValueExpression =   [NSExpression expressionForConstantValue:minValue];
    NSExpression    *maxValueExpression =   [NSExpression expressionForConstantValue:maxValue];
    
    /* min border predicate */
    NSPredicate     *minPredicate =         [NSComparisonPredicate predicateWithLeftExpression:keyPathExpression
                                                                               rightExpression:minValueExpression
                                                                                      modifier:NSDirectPredicateModifier
                                                                                          type:NSGreaterThanOrEqualToPredicateOperatorType
                                                                                       options:NSNormalizedPredicateOption];
    
    /* max border predicate */
    NSPredicate     *maxPredicate =         [NSComparisonPredicate predicateWithLeftExpression:keyPathExpression
                                                                               rightExpression:maxValueExpression
                                                                                      modifier:NSDirectPredicateModifier
                                                                                          type:NSLessThanOrEqualToPredicateOperatorType
                                                                                       options:NSNormalizedPredicateOption];
    /*  return predicate*/
    NSPredicate     *retPredicate =         [NSCompoundPredicate andPredicateWithSubpredicates:@[minPredicate, maxPredicate]];
    
    return  retPredicate;
}

+ (NSExpressionDescription *)managedObjectIDDescription
{
    NSExpressionDescription* objectIdDesc = [[NSExpressionDescription alloc] init];
    objectIdDesc.name = @"objectId";
    objectIdDesc.expression = [NSExpression expressionForEvaluatedObject];
    objectIdDesc.expressionResultType = NSObjectIDAttributeType;
    return objectIdDesc;
}

+ (NSPredicate *)predicateForObjectIDArray:(NSArray *)objectIDArray
{
    NSExpression *leftExpression    = [NSExpression expressionForEvaluatedObject];
    NSExpression *rightExpression   = [NSExpression expressionForConstantValue:objectIDArray];
    
    NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                rightExpression:rightExpression
                                                                       modifier:NSDirectPredicateModifier
                                                                           type:NSInPredicateOperatorType
                                                                        options:NSNormalizedPredicateOption];
    return predicate;
}


+ (NSArray *)checkpoints
{
    NSManagedObjectContext *context = [DMManager managedObjectContext];
    NSFetchRequest *fetchRequest    = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return error ? nil : fetchedObjects;
}

+ (NSArray *)airports
{
    return [self checkpointsWithType:@"A"];
}

+ (NSArray *)borders
{
    return [self checkpointsWithType:@"B"];
}

+ (NSArray *)ports
{
    return [self checkpointsWithType:@"P"];
}

+ (NSArray *)checkpointsWithType:(NSString*)type
{
    NSManagedObjectContext *context = [DMManager managedObjectContext];
    NSFetchRequest *fetchRequest    = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", type];
    fetchRequest.predicate = predicate;
    
    __block NSError *error;
    __block NSArray *fetchedObjects;
    dispatch_sync(dispatch_get_main_queue(), ^(){
        [context performBlockAndWait:^(){
            fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        }];
    });
    
    return error ? nil : fetchedObjects;
}


+ (DMCheckpoint *)checkpointById:(NSString *)checkpointId
{
    return [self checkpointById:checkpointId inManagedObjectContext:[DMManager managedObjectContext]];
}

+ (DMCheckpoint *)checkpointById:(NSString *)checkpointId inManagedObjectContext:(NSManagedObjectContext*)context
{
    DMCheckpoint *managedObject = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ident == %@", checkpointId];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSArray *results = [context executeFetchRequest:fetchRequest
                                              error:nil];
    if ([results count]) {
        managedObject = [results lastObject];
    }
    
    return managedObject;
}

+ (void)cleanDublicates
{
    /*NSManagedObjectContext *mainContext = [DMManager managedObjectContext];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = mainContext;
    
    NSArray *checkpoints = [self checkpoints];
    for (DMCheckpoint *ch in checkpoints) {
        [self clenaDuplForId:ch.ident inManagedContext:context];
    }
    [context save:nil];*/
}

+ (void)clenaDuplForId:(NSString*)ident inManagedContext:(NSManagedObjectContext*)context
{
    DMCheckpoint *managedObject = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ident == %@", ident];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:fetchRequest
                                              error:nil];
    if ([results count] > 1) {
        managedObject = [results lastObject];
        [context deleteObject:managedObject];
    }
}

#pragma mark - CBLocation

- (CLLocation *)clLocation
{
    return [[CLLocation alloc] initWithLatitude:self.latitudeValue longitude:self.longitudeValue];
}

- (NSString *)countryISO
{
    return self.country?self.country.identifier:@"";
}

- (BOOL)ISOCodeSpecified
{
    return (self.countryISO.length == kCountryISOCodeMAXLength);
}


#pragma mark - Public methods

- (DMCheckpointType)checkpointType
{
    if ([self.type isEqualToString:@"B"]) {
        return DMCheckpointTypeBorder;
    }
    else if ([self.type isEqualToString:@"P"]) {
        return DMCheckpointTypePort;
    }
    else {
        return DMCheckpointTypeAirport;
    }
}

- (BOOL)hasAlertToShow
{
    return (self.alert && !self.alert.shownValue);
}

- (void)setAlertShown:(BOOL)shown
{
    self.alert.shownValue = shown;
}

- (void)refreshAlertState
{
    if (self.alert) {
        [self setAlertShown:NO];
    }
    else {
        [DMManager loadAlertForAirportWithID:self.ident
                           completionHandler:^(NSDictionary *alertsDic, BOOL isErrorOccured) {
                               if (!isErrorOccured) {
                                   NSString *text = nil;
                                   NSString *key = DMCheckpointAlertAttributes.text;
                                   for (NSString *dKey in [alertsDic allKeys]) {
                                       if ([key caseInsensitiveCompare:dKey] == NSOrderedSame) {
                                           text = [alertsDic objectForKey:dKey];
                                       }
                                   }
                                   
                                   if (text && [text isKindOfClass:[NSString class]]) {
                                       [self addAlertWithText:text];
                                   }
                               }
                           }];
    }
}

- (void)addAlertWithText:(NSString *)aText
{
    DMCheckpointAlert *alert = [DMCheckpointAlert insertInManagedObjectContext:[DMManager managedObjectContext]];
    alert.checkpoint = self;
    alert.text = aText;
    
    [DMManager saveContext];
}


@end

#import "WMWound.h"
#import "WMWoundType.h"
#import "WMWoundPhoto.h"
#import "WMPatient.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundLocation.h"
#import "WMWoundLocationValue.h"
#import "WMWoundPosition.h"
#import "WMWoundPositionValue.h"
#import "WMWoundLocationPositionJoin.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMWound ()

// Private interface goes here.

@end


@implementation WMWound

+ (NSArray *)pressureUlcerTypeCodes
{
    static NSArray *Pressure_Ulcer_TypeCodes = nil;
    if (nil == Pressure_Ulcer_TypeCodes) {
        Pressure_Ulcer_TypeCodes = [[NSArray alloc] initWithObjects:@"9", @"11", @"12", @"13", @"14", @"15", nil];
    }
    return Pressure_Ulcer_TypeCodes;
}

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMWound *wound = [[WMWound alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWound" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:wound toPersistentStore:store];
	}
    [wound setValue:[wound assignObjectId] forKey:[wound primaryKeyField]];
	return wound;
}

+ (instancetype)instanceWithPatient:(WMPatient *)patient
{
    WMWound *wound = [self instanceWithManagedObjectContext:[patient managedObjectContext] persistentStore:nil];
    wound.patient = patient;
    return wound;
}

+ (NSInteger)woundCountForPatient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWound" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    NSError *error = nil;
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyTryCacheElseNetwork];
    NSInteger count = [managedObjectContext countForFetchRequestAndWait:request options:options error:&error];
    [WMUtilities logError:error];
    return count;
}

+ (WMWound *)woundForPatient:(WMPatient *)patient woundId:(NSString *)woundId
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WCWound" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND wmwound_id == %@", patient, woundId]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (NSArray *)sortedWounds:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    if (nil == managedObjectContext) {
        return [NSArray array];
    }
    // else
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WCWound" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

- (NSInteger)woundPhotosCount
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPhoto" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]];
    NSError *error = nil;
    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return count;
}

+ (NSInteger)woundPhotoCountForWound:(WMWound *)wound
{
    return [wound woundPhotosCount];
}

+ (NSInteger)woundTreatmentCountForWounds:(NSArray *)wounds
{
    if (0 == [wounds count]) {
        return 0;
    }
    // else
    NSInteger count = 0;
    for (WMWound *wound in wounds) {
        count += wound.woundTreatmentGroupCount;
    }
    return count;
}

- (NSArray *)woundTypeForDisplay
{
    if (nil == self.woundType) {
        return [NSArray array];
    }
    // else
    NSMutableArray *woundTypes = [[NSMutableArray alloc] initWithCapacity:4];
    WMWoundType *woundType = self.woundType;
    while (nil != woundType) {
        [woundTypes insertObject:woundType.title atIndex:0];
        woundType = woundType.parent;
    }
    return woundTypes;
}

+ (NSDate *)mostRecentWoundPhotoDateModifiedForWound:(WMWound *)wound
{
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"dateModified"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"dateModified";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundPhoto"];
    request.predicate = [NSPredicate predicateWithFormat:@"wound == %@", wound];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSError *error = nil;
    NSArray *results = [[wound managedObjectContext] executeFetchRequestAndWait:request error:&error];
    if ([results count] == 0)
        return nil;
    // else
    return [results firstObject][@"dateModified"];
}

+ (NSDate *)mostRecentWoundPhotoDateCreatedForWound:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    NSExpression *dateCreatedExpression = [NSExpression expressionForKeyPath:@"dateCreated"];
    NSExpressionDescription *dateCreatedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateCreatedExpressionDescription.name = @"dateCreated";
    dateCreatedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateCreatedExpression]];
    dateCreatedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundPhoto"];
    request.predicate = [NSPredicate predicateWithFormat:@"wound == %@", wound];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateCreatedExpressionDescription];
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequestAndWait:request
                                                 returnManagedObjectIDs:NO
                                                                options:options
                                                                  error:&error];
    if ([results count] == 0)
        return nil;
    // else
    return [results firstObject][@"dateCreated"];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
}

- (NSArray *)woundPositionValuesForJoin:(WMWoundLocationPositionJoin *)woundPositionJoin
                                  value:(id)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPositionValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND woundPosition IN (%@)", self, woundPositionJoin.positions]];
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequestAndWait:request
                                                 returnManagedObjectIDs:NO
                                                                options:options
                                                                  error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    return results;
}

- (WMWoundPositionValue *)woundPositionValueForJoin:(WMWoundLocationPositionJoin *)woundPositionJoin
                                             create:(BOOL)create
                                              value:(id)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WMWoundPositionValue *woundPositionValue = [[self woundPositionValuesForJoin:woundPositionJoin value:value] lastObject];
    if (create && nil == woundPositionValue) {
        woundPositionValue = [WMWoundPositionValue woundPositionValueForWound:self];
        woundPositionValue.value = value;
    }
    return woundPositionValue;
}

- (WMWoundPositionValue *)woundPositionValueForWoundPosition:(WMWoundPosition *)woundPosition
                                                      create:(BOOL)create
                                                       value:(id)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPositionValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND woundPosition == %@", self, woundPosition]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMWoundPositionValue *woundPositionValue = [array lastObject];
    if (create && nil == woundPositionValue) {
        woundPositionValue = [WMWoundPositionValue woundPositionValueForWound:self];
        woundPositionValue.woundPosition = woundPosition;
    }
    return woundPositionValue;
}

- (NSString *)shortName
{
    NSString *string = self.name;
    if ([string length] == 0) {
        string = [self.woundTypeForDisplay componentsJoinedByString:@", "];
        if (0 == [string length]) {
            string = @"Unspecified Wound";
        }
    }
    return string;
}

- (WMWoundPhoto *)lastWoundPhoto
{
    NSArray *objectIDs = self.sortedWoundPhotoIDs;
    if (0 == [objectIDs count]) {
        return nil;
    }
    // else
    return (WMWoundPhoto *)[[self managedObjectContext] objectWithID:[objectIDs lastObject]];
}

- (WMWoundPhoto *)referenceWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectID *objectID = [woundPhoto objectID];
    NSArray *woundPhotoIDs = self.sortedWoundPhotoIDs;
    NSInteger index = [woundPhotoIDs indexOfObject:objectID];
    if (index > 0) {
        return (WMWoundPhoto *)[[self managedObjectContext] objectWithID:[woundPhotoIDs objectAtIndex:(index - 1)]];
    }
    // else
    return (WMWoundPhoto *)[[self managedObjectContext] objectWithID:[woundPhotoIDs lastObject]];
}

- (BOOL)hasPreviousWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectID *objectID = [woundPhoto objectID];
    NSArray *woundPhotoIDs = self.sortedWoundPhotoIDs;
    NSInteger index = [woundPhotoIDs indexOfObject:objectID];
    if (index > 0) {
        return YES;
    }
    // else
    return NO;
}

- (NSArray *)sortedWoundPhotoIDs
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPhoto" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    [request setResultType:NSManagedObjectIDResultType];
    NSError *error = nil;
    NSArray *objectIDs = [managedObjectContext executeFetchRequestAndWait:request returnManagedObjectIDs:YES error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    return objectIDs;
}

- (WMWoundTreatmentGroup *)lastWoundTreatmentGroup
{
    return [self.sortedWoundTreatments lastObject];
}

- (WMWoundPhoto *)woundPhotoForDate:(NSDate *)date
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateCreated == %@", date];
    return [[[self.photos allObjects] filteredArrayUsingPredicate:predicate] lastObject];
}

- (NSInteger)woundPositionCount
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPositionValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]];
    NSError *error = nil;
    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return count;
}

- (NSInteger)woundTreatmentGroupCount
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]];
    NSError *error = nil;
    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return count;
}

- (NSDictionary *)minimumAndMaximumWoundPhotoDates
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPhoto" inManagedObjectContext:managedObjectContext]];
    // Specify that the request should return dictionaries.
    [request setResultType:NSDictionaryResultType];
    // MIN: Create an expression for the key path.
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"dateCreated"];
    // Create an expression to represent the minimum value at the key path 'creationDate'
    NSExpression *expression = [NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    // Create an expression description using the expression and returning a date.
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:@"minDate"];
    [expressionDescription setExpression:expression];
    [expressionDescription setExpressionResultType:NSDateAttributeType];
    // Set the request's properties to fetch just the property represented by the expressions.
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (objects == nil) {
        [WMUtilities logError:error];
    } else if ([objects count] > 0) {
        [dictionary addEntriesFromDictionary:objects[0]];
    }
    // MAX: Create an expression to represent the minimum value at the key path 'creationDate'
    expression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    // Create an expression description using the maxExpression and returning a date.
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:@"maxDate"];
    [expressionDescription setExpression:expression];
    // Set the request's properties to fetch just the property represented by the expressions.
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    // Execute the fetch.
    objects = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (objects == nil) {
        [WMUtilities logError:error];
    } else if ([objects count] > 0) {
        [dictionary addEntriesFromDictionary:objects[0]];
    }
    return dictionary;
}

- (NSArray *)sortedPositionValues
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPositionValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"woundPosition.sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

- (NSArray *)sortedWoundPhotos
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundPhoto" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

- (NSArray *)sortedWoundMeasurementsAscending:(BOOL)ascending
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WCWoundMeasurementGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:ascending]]];
    NSError *error = nil;
    NSArray *woundMeasurements = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return woundMeasurements;
}

- (NSArray *)sortedWoundMeasurements
{
    return [self sortedWoundMeasurementsAscending:NO];
}

- (NSArray *)sortedWoundTreatments
{
    return [self sortedWoundMeasurementsAscending:YES];
}

- (NSArray *)sortedWoundTreatmentsAscending:(BOOL)ascending
{
    return [[self.treatmentGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:ascending]]];
}

- (NSString *)positionValuesForDisplay
{
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:16];
    for (WMWoundPositionValue *positionValue in self.sortedPositionValues) {
        [values addObject:positionValue.woundPosition.title];
    }
    return [values componentsJoinedByString:@","];
}

- (NSString *)woundLocationAndPositionForDisplay
{
    if (nil == self.locationValue) {
        return nil;
    }
    // else
    NSString *string = [self.locationValue.location.title stringByAppendingString:@": "];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4];
    // get position
    NSArray *sortedPositionValues = self.sortedPositionValues;
    for (WMWoundPositionValue *positionValue in sortedPositionValues) {
        NSString *string = ([positionValue.woundPosition.valueTypeCode intValue] == GroupValueTypeCodeValue1NavigateToOptions ?  positionValue.woundPosition.commonTitle:positionValue.woundPosition.title);
        if ([positionValue.value length] > 1) {
            string = [string stringByAppendingFormat:@": %@", positionValue.value];
        }
        [array addObject:string];
    }
    return [string stringByAppendingString:[array componentsJoinedByString:@", "]];
}

- (WMWoundTreatmentGroup *)woundTreatmentGroupClosestToDate:(NSDate *)date
{
    NSArray *sortedWoundTreatments = self.sortedWoundTreatments;
    if (0 == [sortedWoundTreatments count]) {
        return nil;
    }
    // else
    NSTimeInterval dateTimeInterval = ABS([date timeIntervalSinceReferenceDate]);
    CGFloat delta = MAXFLOAT;
    WMWoundTreatmentGroup *result = nil;
    for (WMWoundTreatmentGroup *woundTreatmentGroup in sortedWoundTreatments) {
        CGFloat deltaCandidate = ABS([woundTreatmentGroup.dateCreated timeIntervalSinceReferenceDate] - dateTimeInterval);
        if (deltaCandidate < delta) {
            result = woundTreatmentGroup;
            delta = deltaCandidate;
        }
    }
    return result;
}

@end

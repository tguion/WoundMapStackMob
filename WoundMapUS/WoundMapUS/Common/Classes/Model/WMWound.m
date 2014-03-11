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
    return [WMWound MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                          inContext:[patient managedObjectContext]];
}

+ (WMWound *)woundForPatient:(WMPatient *)patient woundFFURL:(NSString *)ffUrl
{
    return (WMWound *)[WMWound MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND ffUrl == %@", patient, ffUrl]
                                               inContext:[patient managedObjectContext]];
}

+ (NSArray *)sortedWounds:(WMPatient *)patient
{
    return [WMWound MR_findAllSortedBy:@"sortRank"
                             ascending:YES
                         withPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                             inContext:[patient managedObjectContext]];
}

- (NSInteger)woundPhotosCount
{
    return [WMWoundPhoto MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]
                                               inContext:[self managedObjectContext]];
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
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundPhoto"];
    request.predicate = [NSPredicate predicateWithFormat:@"wound == %@", wound];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    id result = [WMWoundPhoto MR_executeFetchRequestAndReturnFirstObject:request inContext:[wound managedObjectContext]];
    return result[@"updatedAt"];
}

+ (NSDate *)mostRecentWoundPhotoDateCreatedForWound:(WMWound *)wound
{
    NSExpression *dateCreatedExpression = [NSExpression expressionForKeyPath:@"createdAt"];
    NSExpressionDescription *dateCreatedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateCreatedExpressionDescription.name = @"createdAt";
    dateCreatedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateCreatedExpression]];
    dateCreatedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundPhoto"];
    request.predicate = [NSPredicate predicateWithFormat:@"wound == %@", wound];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateCreatedExpressionDescription];
    id result = [WMWoundPhoto MR_executeFetchRequestAndReturnFirstObject:request inContext:[wound managedObjectContext]];
    return result[@"createdAt"];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (NSArray *)woundPositionValuesForJoin:(WMWoundLocationPositionJoin *)woundPositionJoin
                                  value:(id)value
{
    return [WMWoundPositionValue MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND woundPosition IN (%@)", self, woundPositionJoin.positions]
                                               inContext:[self managedObjectContext]];
}

- (WMWoundPositionValue *)woundPositionValueForJoin:(WMWoundLocationPositionJoin *)woundPositionJoin
                                             create:(BOOL)create
                                              value:(id)value
{
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
    WMWoundPositionValue *woundPositionValue = [WMWoundPositionValue MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND woundPosition == %@", self, woundPosition]
                                                                                     inContext:managedObjectContext];
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
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
    [request setResultType:NSManagedObjectIDResultType];
    return [WMWoundPhoto MR_executeFetchRequest:request inContext:managedObjectContext];
}

- (WMWoundTreatmentGroup *)lastWoundTreatmentGroup
{
    return [self.sortedWoundTreatments lastObject];
}

- (WMWoundPhoto *)woundPhotoForDate:(NSDate *)date
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"createdAt == %@", date];
    return [[[self.photos allObjects] filteredArrayUsingPredicate:predicate] lastObject];
}

- (NSInteger)woundPositionCount
{
    return [WMWoundPositionValue MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]
                                                       inContext:[self managedObjectContext]];
}

- (NSInteger)woundTreatmentGroupCount
{
    return [WMWoundTreatmentGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@", self]
                                                        inContext:[self managedObjectContext]];
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
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"createdAt"];
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
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
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
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:ascending]]];
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
    return [[self.treatmentGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:ascending]]];
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
        CGFloat deltaCandidate = ABS([woundTreatmentGroup.createdAt timeIntervalSinceReferenceDate] - dateTimeInterval);
        if (deltaCandidate < delta) {
            result = woundTreatmentGroup;
            delta = deltaCandidate;
        }
    }
    return result;
}

@end

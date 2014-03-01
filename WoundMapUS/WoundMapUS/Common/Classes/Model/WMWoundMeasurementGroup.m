#import "WMWoundMeasurementGroup.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundMeasurement.h"
#import "WMWoundMeasurementValue.h"
#import "WMWoundPhoto.h"
#import "WMAmountQualifier.h"
#import "WMWoundOdor.h"
#import "WMUtilities.h"
#import "StackMob.h"

NSString * const kDimensionsWoundMeasurementTitle = @"Dimensions";
NSString * const kDimensionWidthWoundMeasurementTitle = @"Width";
NSString * const kDimensionLengthWoundMeasurementTitle = @"Length";
NSString * const kDimensionDepthWoundMeasurementTitle = @"Depth";
NSString * const kDimensionUndermineTunnelMeasurementTitle = @"Undermining & Tunneling";

@interface WMWoundMeasurementGroup ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementGroup

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMWoundMeasurementGroup *woundMeasurementGroup = [[WMWoundMeasurementGroup alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementGroup" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundMeasurementGroup toPersistentStore:store];
	}
    [woundMeasurementGroup setValue:[woundMeasurementGroup assignObjectId] forKey:[woundMeasurementGroup primaryKeyField]];
	return woundMeasurementGroup;
}

+ (WMWoundMeasurementGroup *)woundMeasurementGroupInstanceForWound:(WMWound *)wound woundPhoto:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    NSAssert([managedObjectContext isEqual:[wound managedObjectContext]], @"Invalid mocs");
    WMWoundMeasurementGroup *woundMeasurementGroup = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
    woundMeasurementGroup.wound = wound;
    woundMeasurementGroup.woundPhoto = woundPhoto;
    return woundMeasurementGroup;
}

+ (WMWoundMeasurementGroup *)woundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    return [self woundMeasurementGroupForWoundPhoto:woundPhoto create:YES];
}

+ (WMWoundMeasurementGroup *)woundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto create:(BOOL)create
{
    // check for existing group
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"woundPhoto == %@", woundPhoto]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    NSError __autoreleasing *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundMeasurementGroup *woundMeasurementGroup = [array lastObject];
    if (create && nil == woundMeasurementGroup) {
        woundMeasurementGroup = [self instanceWithManagedObjectContext:[woundPhoto managedObjectContext] persistentStore:nil];
        woundMeasurementGroup.woundPhoto = woundPhoto;
        NSAssert(nil != woundPhoto.wound, @"woundPhoto must be associated with a wound");
        woundMeasurementGroup.wound = woundPhoto.wound;
    }
    return woundMeasurementGroup;
}

+ (NSDate *)mostRecentWoundMeasurementGroupDateModified:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"dateModified"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"dateModified";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundMeasurementGroup"];
    request.predicate = [NSPredicate predicateWithFormat:@"woundPhoto == %@", woundPhoto];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequestAndWait:request
                                                 returnManagedObjectIDs:NO
                                                                options:options
                                                                  error:&error];
    if ([results count] == 0)
        return nil;
    // else
    return [results firstObject][@"dateModified"];
}

+ (NSDate *)mostRecentWoundMeasurementGroupDateModifiedForDimensions:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"dateModified"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"dateModified";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundMeasurementValue"];
    request.predicate = [NSPredicate predicateWithFormat:@"group.woundPhoto == %@ AND title IN (%@)", woundPhoto, @[kDimensionWidthWoundMeasurementTitle, kDimensionLengthWoundMeasurementTitle, kDimensionDepthWoundMeasurementTitle, kDimensionUndermineTunnelMeasurementTitle]];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequestAndWait:request
                                                 returnManagedObjectIDs:NO
                                                                options:options
                                                                  error:&error];
    if ([results count] == 0)
        return nil;
    // else
    return [results firstObject][@"dateModified"];
}

+ (NSDate *)mostRecentWoundMeasurementGroupDateCreatedForDimensions:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSExpression *dateCreatedExpression = [NSExpression expressionForKeyPath:@"dateCreated"];
    NSExpressionDescription *dateCreatedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateCreatedExpressionDescription.name = @"dateCreated";
    dateCreatedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateCreatedExpression]];
    dateCreatedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundMeasurementValue"];
    request.predicate = [NSPredicate predicateWithFormat:@"group.woundPhoto == %@ AND title IN (%@)", woundPhoto, @[kDimensionWidthWoundMeasurementTitle, kDimensionLengthWoundMeasurementTitle, kDimensionDepthWoundMeasurementTitle, kDimensionUndermineTunnelMeasurementTitle]];
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

+ (NSDate *)mostRecentWoundMeasurementGroupDateModifiedExcludingDimensions:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"dateModified"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"dateModified";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundMeasurementValue"];
    request.predicate = [NSPredicate predicateWithFormat:@"group.woundPhoto == %@ AND NONE title IN (%@)", woundPhoto, @[kDimensionWidthWoundMeasurementTitle, kDimensionLengthWoundMeasurementTitle, kDimensionDepthWoundMeasurementTitle, kDimensionUndermineTunnelMeasurementTitle]];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequestAndWait:request
                                                 returnManagedObjectIDs:NO
                                                                options:options
                                                                  error:&error];
    if ([results count] == 0)
        return nil;
    // else
    return [results firstObject][@"dateModified"];
}

+ (WMWoundMeasurementGroup *)activeWoundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"woundPhoto == %@ AND status.activeFlag == YES AND closedFlag == NO", woundPhoto]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (NSInteger)closeWoundAssessmentGroupsCreatedBefore:(NSDate *)date
                                             patient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND dateCreated < %@", patient, date]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
        return 0;
    }
	// else
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (BOOL)woundMeasurementGroupsHaveHistoryForWound:(WMWound *)wound
{
    return [self woundMeasurementGroupsInactiveCountForWound:wound] > 0;
}

+ (NSInteger)woundMeasurementGroupsCountForWound:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@", wound]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

+ (NSInteger)woundMeasurementGroupsInactiveCountForWound:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND (status.activeFlag == NO OR closedFlag == YES)", wound]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    self.dateModified = [NSDate date];
}

- (WMWoundMeasurementValue *)measurementValueWidth
{
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                        parentWoundMeasurement:nil
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]
                                                               persistentStore:nil];
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionWidthWoundMeasurementTitle
                                    parentWoundMeasurement:measurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]
                                           persistentStore:nil];
    return [self woundMeasurementValueForWoundMeasurement:measurement
                                                   create:YES
                                                    value:nil];
}

- (WMWoundMeasurementValue *)measurementValueLength
{
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                        parentWoundMeasurement:nil
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]
                                                               persistentStore:nil];
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionLengthWoundMeasurementTitle
                                    parentWoundMeasurement:measurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]
                                           persistentStore:nil];
    return [self woundMeasurementValueForWoundMeasurement:measurement
                                                   create:YES
                                                    value:nil];
}

- (WMWoundMeasurementValue *)measurementValueDepth
{
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                        parentWoundMeasurement:nil
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]
                                                               persistentStore:nil];
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionDepthWoundMeasurementTitle
                                    parentWoundMeasurement:measurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]
                                           persistentStore:nil];
    return [self woundMeasurementValueForWoundMeasurement:measurement
                                                   create:YES
                                                    value:nil];
}

// determine the latest date for a length, width or depth measurement
- (NSDate *)lastWoundMeasurementDate
{
    NSDate *dateModified = nil;
    // get the parent WMWoundMeasurement
    WMWoundMeasurement *parentMeasurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                              parentWoundMeasurement:nil
                                                                              create:NO
                                                                managedObjectContext:[self managedObjectContext]
                                                                     persistentStore:nil];
    // get the width WMWoundMeasurement
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionWidthWoundMeasurementTitle
                                                        parentWoundMeasurement:parentMeasurement
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]
                                                               persistentStore:nil];
    WMWoundMeasurementValue *woundMeasurementValue = [self woundMeasurementValueForWoundMeasurement:measurement
                                                                                             create:NO
                                                                                              value:nil];
    if (nil != woundMeasurementValue) {
        dateModified = woundMeasurementValue.dateModified;
    }
    // get the length WMWoundMeasurement
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionLengthWoundMeasurementTitle
                                    parentWoundMeasurement:parentMeasurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]
                                           persistentStore:nil];
    woundMeasurementValue = [self woundMeasurementValueForWoundMeasurement:measurement
                                                                    create:NO
                                                                     value:nil];
    if (nil != woundMeasurementValue) {
        dateModified = [woundMeasurementValue.dateModified laterDate:dateModified];
    }
    // get the depth WMWoundMeasurement
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionDepthWoundMeasurementTitle
                                    parentWoundMeasurement:parentMeasurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]
                                           persistentStore:nil];
    woundMeasurementValue = [self woundMeasurementValueForWoundMeasurement:measurement
                                                                    create:NO
                                                                     value:nil];
    if (nil != woundMeasurementValue) {
        dateModified = [woundMeasurementValue.dateModified laterDate:dateModified];
    }
    return dateModified;
}

- (NSDate *)dateModifiedExludingMeasurement
{
    NSArray *values = [[self.values allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:NO]]];
    NSDate *dateModified = nil;
    NSArray *measurementTitles = @[kDimensionWidthWoundMeasurementTitle, kDimensionLengthWoundMeasurementTitle, kDimensionDepthWoundMeasurementTitle, kDimensionUndermineTunnelMeasurementTitle];
    for (WMWoundMeasurementValue *value in values) {
        if (![measurementTitles containsObject:value.woundMeasurement.title]) {
            dateModified = value.dateModified;
            break;
        }
    }
    return dateModified;
}

- (NSInteger)tunnelingValueCount
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WCWoundMeasurementTunnelValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@", self]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

- (NSInteger)underminingValueCount
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WCWoundMeasurementUndermineValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@", self]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

- (BOOL)hasWoundMeasurementValuesForWoundMeasurementAndChildren:(WMWoundMeasurement *)woundMeasurement
{
    NSMutableSet *woundMeasurements = [[NSMutableSet alloc] initWithCapacity:16];
    [woundMeasurement aggregateWoundMeasurements:woundMeasurements];
    NSMutableSet *woundMeasurementsForValues = [[self.valuesFromFetch valueForKeyPath:@"woundMeasurement"] mutableCopy];
    return [woundMeasurementsForValues intersectsSet:woundMeasurements];
}

- (WMWoundMeasurementValue *)woundMeasurementValueForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
                                                               create:(BOOL)create
                                                                value:(id)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSAssert([[woundMeasurement managedObjectContext] isEqual:managedObjectContext], @"Invalid mocs");
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement == %@", self, woundMeasurement];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, [NSPredicate predicateWithFormat:@"value == %@", value]]];
    }
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
	// else
    WMWoundMeasurementValue *woundMeasurementValue = [array lastObject];
    if (create && nil == woundMeasurementValue) {
        woundMeasurementValue = [WMWoundMeasurementValue instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        woundMeasurementValue.woundMeasurement = woundMeasurement;
        woundMeasurementValue.value = value;
        woundMeasurementValue.title = woundMeasurement.title;
        [self addValuesObject:woundMeasurementValue];
    }
    return woundMeasurementValue;
}

- (void)removeWoundMeasurementValuesForParentWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement.parentMeasurement == %@", self, woundMeasurement];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *values = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
	// else
    for (WMWoundMeasurementValue *woundMeasurementValue in values) {
        [self removeValuesObject:woundMeasurementValue];
        [managedObjectContext deleteObject:woundMeasurementValue];
    }
}

- (WMWoundMeasurement *)woundMeasurementForParentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement
{
    return [[[self woundMeasurementValuesForParentWoundMeasurement:parentWoundMeasurement] lastObject] woundMeasurement];
}

- (NSSet *)valuesFromFetch
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@", self]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
        return 0;
    }
	// else
    return [NSSet setWithArray:array];
}

- (NSArray *)woundMeasurementValuesWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement == %@", self, woundMeasurement]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"woundMeasurement.sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
        return 0;
    }
	// else
    return array;
}

- (NSArray *)woundMeasurementValuesForParentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement.parentMeasurement == %@", self, parentWoundMeasurement]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"woundMeasurement.sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
        return 0;
    }
	// else
    return array;
}

- (NSArray *)woundMeasurementValuesForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement == %@", self, woundMeasurement]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
        return 0;
    }
	// else
    return array;
}

- (NSString *)displayValueForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    NSString *displayValue = nil;
    if (woundMeasurement.hasChildrenWoundMeasurements) {
        // get all values for children
        NSArray *values = [self woundMeasurementValuesForParentWoundMeasurement:woundMeasurement];
        if ([woundMeasurement.title isEqualToString:kDimensionsWoundMeasurementTitle]) {
            // special format
            NSMutableArray *dimensions = [[NSMutableArray alloc] initWithCapacity:4];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"woundMeasurement.title == %@", kDimensionLengthWoundMeasurementTitle];
            WMWoundMeasurementValue *value = [[values filteredArrayUsingPredicate:predicate] lastObject];
            if (nil != value && [value.value length] > 0 && ![value.value isEqualToString:@"NaN"]) {
                [dimensions addObject:value.value];
            }
            predicate = [NSPredicate predicateWithFormat:@"woundMeasurement.title == %@", kDimensionWidthWoundMeasurementTitle];
            value = [[values filteredArrayUsingPredicate:predicate] lastObject];
            if (nil != value && [value.value length] > 0 && ![value.value isEqualToString:@"NaN"]) {
                [dimensions addObject:value.value];
            }
            predicate = [NSPredicate predicateWithFormat:@"woundMeasurement.title == %@", kDimensionDepthWoundMeasurementTitle];
            value = [[values filteredArrayUsingPredicate:predicate] lastObject];
            if (nil != value && [value.value length] > 0 && ![value.value isEqualToString:@"NaN"]) {
                [dimensions addObject:value.value];
            }
            displayValue = [dimensions componentsJoinedByString:@"x"];
        } else {
            // get value for woundMeasurement
            WMWoundMeasurementValue *value = [values lastObject];
            if (nil != value) {
                if (nil != value.amountQualifier) {
                    displayValue = value.amountQualifier.title;
                } else if (nil != value.odor) {
                    displayValue = value.odor.title;
                } else if ([woundMeasurement.valueTypeCode intValue] == GroupValueTypeCodeInlineExtendsTextField) {
                    displayValue = [NSString stringWithFormat:@"Extends out %@ cm", value.value];
                } else if (nil == value.value) {
                    displayValue = value.woundMeasurement.title;
                } else {
                    displayValue = value.value;
                }
            }
        }
    } else {
        // get value for woundMeasurement
        WMWoundMeasurementValue *value = [self woundMeasurementValueForWoundMeasurement:woundMeasurement
                                                                                 create:NO
                                                                                  value:nil];
        displayValue = value.displayValue;
    }
    return displayValue;
}

#pragma mark - Normalization

- (NSDecimalNumber *)totalPercentageAmount:(WMWoundMeasurement *)parentWoundMeasurement
{
    static NSDecimalNumberHandler* roundingBehavior = nil;
    if (roundingBehavior == nil) {
        roundingBehavior = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain
                                                                          scale:0
                                                               raiseOnExactness:NO
                                                                raiseOnOverflow:NO
                                                               raiseOnUnderflow:NO
                                                            raiseOnDivideByZero:NO];
    }
    NSArray *values = [self woundMeasurementValuesForParentWoundMeasurement:parentWoundMeasurement];
    NSDecimalNumber *amount = [NSDecimalNumber zero];
    for (WMWoundMeasurementValue *value in values) {
        amount = [amount decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:value.value]];
    }
    amount = [amount decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return amount;
}

- (void)normalizeInputsForParentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement
{
    static NSDecimalNumberHandler* roundingBehavior = nil;
    if (roundingBehavior == nil) {
        roundingBehavior = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain
                                                                          scale:0
                                                               raiseOnExactness:NO
                                                                raiseOnOverflow:NO
                                                               raiseOnUnderflow:NO
                                                            raiseOnDivideByZero:NO];
    }
    NSDecimalNumber *sum = [self totalPercentageAmount:parentWoundMeasurement];
    if ([sum floatValue] == 0.0) {
        return;
    }
    // else
    NSDecimalNumber *multiplier = [[NSDecimalNumber decimalNumberWithString:@"100.0"] decimalNumberByDividingBy:sum];
    NSArray *values = [self woundMeasurementValuesForParentWoundMeasurement:parentWoundMeasurement];
    for (WMWoundMeasurementValue *value in values) {
        NSDecimalNumber *number = [[NSDecimalNumber decimalNumberWithString:value.value] decimalNumberByMultiplyingBy:multiplier];
        number = [number decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
        value.value = [number stringValue];
    }
}

- (BOOL)isClosed
{
    return self.closedFlagValue;
}

@end

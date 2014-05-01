#import "WMWoundMeasurementGroup.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundMeasurement.h"
#import "WMWoundMeasurementValue.h"
#import "WMWoundPhoto.h"
#import "WMAmountQualifier.h"
#import "WMWoundOdor.h"
#import "WMInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

NSString * const kDimensionsWoundMeasurementTitle = @"Dimensions";
NSString * const kDimensionWidthWoundMeasurementTitle = @"Width";
NSString * const kDimensionLengthWoundMeasurementTitle = @"Length";
NSString * const kDimensionDepthWoundMeasurementTitle = @"Depth";
NSString * const kDimensionUndermineTunnelMeasurementTitle = @"Undermining & Tunneling";

@interface WMWoundMeasurementGroup ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementGroup

+ (WMWoundMeasurementGroup *)woundMeasurementGroupInstanceForWound:(WMWound *)wound woundPhoto:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    NSAssert([managedObjectContext isEqual:[wound managedObjectContext]], @"Invalid mocs");
    WMWoundMeasurementGroup *woundMeasurementGroup = [WMWoundMeasurementGroup MR_createInContext:managedObjectContext];
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
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    WMWoundMeasurementGroup *woundMeasurementGroup = [WMWoundMeasurementGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"woundPhoto == %@", woundPhoto] sortedBy:@"createdAt" ascending:NO inContext:managedObjectContext];
    if (create && nil == woundMeasurementGroup) {
        woundMeasurementGroup = [WMWoundMeasurementGroup MR_createInContext:managedObjectContext];
        woundMeasurementGroup.woundPhoto = woundPhoto;
        NSAssert(nil != woundPhoto.wound, @"woundPhoto must be associated with a wound");
        woundMeasurementGroup.wound = woundPhoto.wound;
    }
    return woundMeasurementGroup;
}

+ (NSDate *)mostRecentWoundMeasurementGroupDateModified:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundMeasurementGroup"];
    request.predicate = [NSPredicate predicateWithFormat:@"woundPhoto == %@", woundPhoto];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMWoundMeasurementGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    return date[@"updatedAt"];
}

+ (NSDate *)mostRecentWoundMeasurementGroupDateModifiedForDimensions:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundMeasurementValue"];
    request.predicate = [NSPredicate predicateWithFormat:@"group.woundPhoto == %@ AND title IN (%@)", woundPhoto, @[kDimensionWidthWoundMeasurementTitle, kDimensionLengthWoundMeasurementTitle, kDimensionDepthWoundMeasurementTitle, kDimensionUndermineTunnelMeasurementTitle]];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMWoundMeasurementValue MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    return date[@"updatedAt"];
}

+ (NSDate *)mostRecentWoundMeasurementGroupDateCreatedForDimensions:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSExpression *dateCreatedExpression = [NSExpression expressionForKeyPath:@"createdAt"];
    NSExpressionDescription *dateCreatedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateCreatedExpressionDescription.name = @"createdAt";
    dateCreatedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateCreatedExpression]];
    dateCreatedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundMeasurementValue"];
    request.predicate = [NSPredicate predicateWithFormat:@"group.woundPhoto == %@ AND title IN (%@)", woundPhoto, @[kDimensionWidthWoundMeasurementTitle, kDimensionLengthWoundMeasurementTitle, kDimensionDepthWoundMeasurementTitle, kDimensionUndermineTunnelMeasurementTitle]];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateCreatedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMWoundMeasurementValue MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    return date[@"createdAt"];
}

+ (NSDate *)mostRecentWoundMeasurementGroupDateModifiedExcludingDimensions:(WMWoundPhoto *)woundPhoto
{
    NSManagedObjectContext *managedObjectContext = [woundPhoto managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundMeasurementValue"];
    request.predicate = [NSPredicate predicateWithFormat:@"group.woundPhoto == %@ AND NONE title IN (%@)", woundPhoto, @[kDimensionWidthWoundMeasurementTitle, kDimensionLengthWoundMeasurementTitle, kDimensionDepthWoundMeasurementTitle, kDimensionUndermineTunnelMeasurementTitle]];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMWoundMeasurementValue MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    return date[@"updatedAt"];
}

+ (WMWoundMeasurementGroup *)activeWoundMeasurementGroupForWoundPhoto:(WMWoundPhoto *)woundPhoto
{
    return [WMWoundMeasurementGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"woundPhoto == %@ AND status.activeFlag == YES AND closedFlag == NO", woundPhoto]
                                                     sortedBy:WMWoundMeasurementGroupAttributes.createdAt
                                                    ascending:NO
                                                    inContext:[woundPhoto managedObjectContext]];
}

+ (NSInteger)closeWoundAssessmentGroupsCreatedBefore:(NSDate *)date
                                               wound:(WMWound *)wound
{
    NSArray *array = [WMWoundMeasurementGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND closedFlag == NO AND createdAt < %@", wound, date] inContext:[wound managedObjectContext]];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (BOOL)woundMeasurementGroupsHaveHistoryForWound:(WMWound *)wound
{
    return [self woundMeasurementGroupsInactiveCountForWound:wound] > 0;
}

+ (NSInteger)woundMeasurementGroupsCountForWound:(WMWound *)wound
{
    return [WMWoundMeasurementGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@", wound] inContext:[wound managedObjectContext]];
}

+ (NSInteger)woundMeasurementGroupsInactiveCountForWound:(WMWound *)wound
{
    return [WMWoundMeasurementGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND (status.activeFlag == NO OR closedFlag == YES)", wound] inContext:[wound managedObjectContext]];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    // initial status
    self.status = [WMInterventionStatus initialInterventionStatus:[self managedObjectContext]];
}

- (WMWoundMeasurementValue *)measurementValueWidth
{
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                        parentWoundMeasurement:nil
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]];
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionWidthWoundMeasurementTitle
                                    parentWoundMeasurement:measurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]];
    return [self woundMeasurementValueForWoundMeasurement:measurement
                                                   create:YES
                                                    value:nil];
}

- (WMWoundMeasurementValue *)measurementValueLength
{
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                        parentWoundMeasurement:nil
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]];
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionLengthWoundMeasurementTitle
                                    parentWoundMeasurement:measurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]];
    return [self woundMeasurementValueForWoundMeasurement:measurement
                                                   create:YES
                                                    value:nil];
}

- (WMWoundMeasurementValue *)measurementValueDepth
{
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                        parentWoundMeasurement:nil
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]];
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionDepthWoundMeasurementTitle
                                    parentWoundMeasurement:measurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]];
    return [self woundMeasurementValueForWoundMeasurement:measurement
                                                   create:YES
                                                    value:nil];
}

- (BOOL)hasInterventionEvents
{
    return [self.interventionEvents count] > 0;
}

// determine the latest date for a length, width or depth measurement
- (NSDate *)lastWoundMeasurementDate
{
    NSDate *updatedAt = nil;
    // get the parent WMWoundMeasurement
    WMWoundMeasurement *parentMeasurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionsWoundMeasurementTitle
                                                              parentWoundMeasurement:nil
                                                                              create:NO
                                                                managedObjectContext:[self managedObjectContext]];
    // get the width WMWoundMeasurement
    WMWoundMeasurement *measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionWidthWoundMeasurementTitle
                                                        parentWoundMeasurement:parentMeasurement
                                                                        create:NO
                                                          managedObjectContext:[self managedObjectContext]];
    WMWoundMeasurementValue *woundMeasurementValue = [self woundMeasurementValueForWoundMeasurement:measurement
                                                                                             create:NO
                                                                                              value:nil];
    if (nil != woundMeasurementValue) {
        updatedAt = woundMeasurementValue.updatedAt;
    }
    // get the length WMWoundMeasurement
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionLengthWoundMeasurementTitle
                                    parentWoundMeasurement:parentMeasurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]];
    woundMeasurementValue = [self woundMeasurementValueForWoundMeasurement:measurement
                                                                    create:NO
                                                                     value:nil];
    if (nil != woundMeasurementValue) {
        updatedAt = [woundMeasurementValue.updatedAt laterDate:updatedAt];
    }
    // get the depth WMWoundMeasurement
    measurement = [WMWoundMeasurement woundMeasureForTitle:kDimensionDepthWoundMeasurementTitle
                                    parentWoundMeasurement:parentMeasurement
                                                    create:NO
                                      managedObjectContext:[self managedObjectContext]];
    woundMeasurementValue = [self woundMeasurementValueForWoundMeasurement:measurement
                                                                    create:NO
                                                                     value:nil];
    if (nil != woundMeasurementValue) {
        updatedAt = [woundMeasurementValue.updatedAt laterDate:updatedAt];
    }
    return updatedAt;
}

- (NSDate *)dateModifiedExludingMeasurement
{
    NSArray *values = [[self.values allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    NSDate *updatedAt = nil;
    NSArray *measurementTitles = @[kDimensionWidthWoundMeasurementTitle, kDimensionLengthWoundMeasurementTitle, kDimensionDepthWoundMeasurementTitle, kDimensionUndermineTunnelMeasurementTitle];
    for (WMWoundMeasurementValue *value in values) {
        if (![measurementTitles containsObject:value.woundMeasurement.title]) {
            updatedAt = value.updatedAt;
            break;
        }
    }
    return updatedAt;
}

- (NSInteger)tunnelingValueCount
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurementValueType == %d", self, kWoundMeasurementValueTypeTunnel]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

- (NSInteger)underminingValueCount
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurementValueType == %d", self, kWoundMeasurementValueTypeUndermine]];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement == %@", self, woundMeasurement];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, [NSPredicate predicateWithFormat:@"value == %@", value]]];
    }
    WMWoundMeasurementValue *woundMeasurementValue = [WMWoundMeasurementValue MR_findFirstWithPredicate:predicate inContext:[woundMeasurement managedObjectContext]];
    if (create && nil == woundMeasurementValue) {
        woundMeasurementValue = [WMWoundMeasurementValue MR_createInContext:[woundMeasurement managedObjectContext]];
        woundMeasurementValue.woundMeasurement = woundMeasurement;
        woundMeasurementValue.value = value;
        woundMeasurementValue.title = woundMeasurement.title;
        [self addValuesObject:woundMeasurementValue];
    }
    return woundMeasurementValue;
}

- (void)removeWoundMeasurementValuesForParentWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    NSManagedObjectContext *managedObjectContext = [woundMeasurement managedObjectContext];
    NSArray *values = [WMWoundMeasurementValue MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement.parentMeasurement == %@", self, woundMeasurement] inContext:managedObjectContext];
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
    return [NSSet setWithArray:[WMWoundMeasurementValue MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"group == %@", self] inContext:[self managedObjectContext]]];
}

- (NSArray *)woundMeasurementValuesWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    return [WMWoundMeasurementValue MR_findAllSortedBy:@"woundMeasurement.sortRank" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement == %@", self, woundMeasurement] inContext:[self managedObjectContext]];
}

- (NSArray *)woundMeasurementValuesForParentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement
{
    return [WMWoundMeasurementValue MR_findAllSortedBy:@"woundMeasurement.sortRank" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement.parentMeasurement == %@", self, parentWoundMeasurement] inContext:[self managedObjectContext]];
}

- (NSArray *)woundMeasurementValuesForWoundMeasurement:(WMWoundMeasurement *)woundMeasurement
{
    return [WMWoundMeasurementValue MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundMeasurement == %@", self, woundMeasurement] inContext:[self managedObjectContext]];
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

#pragma mark - Events

- (WMInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                  title:(NSString *)title
                                              valueFrom:(id)valueFrom
                                                valueTo:(id)valueTo
                                                   type:(WMInterventionEventType *)type
                                            participant:(WMParticipant *)participant
                                                 create:(BOOL)create
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMInterventionEvent *event = [WMInterventionEvent interventionEventForWoundMeasurementGroup:self
                                                                                     changeType:changeType
                                                                                          title:title
                                                                                      valueFrom:valueFrom
                                                                                        valueTo:valueTo
                                                                                           type:type
                                                                                    participant:participant
                                                                                         create:create
                                                                           managedObjectContext:managedObjectContext];
    event.measurementGroup = self;
    return event;
}

- (NSArray *)woundMeasurementValuesAdded
{
    NSDictionary *committedValuesMap = [self committedValuesForKeys:@[@"values"]];
    NSSet *committedValues = [committedValuesMap objectForKey:@"values"];
    if ([committedValues isKindOfClass:[NSNull class]]) {
        return @[];
    }
    // else
    NSMutableSet *addedValues = [self.values mutableCopy];
    [addedValues minusSet:committedValues];
    return [addedValues allObjects];
}

- (NSArray *)woundMeasurementValuesRemoved
{
    NSDictionary *committedValuesMap = [self committedValuesForKeys:@[@"values"]];
    NSSet *committedValues = [committedValuesMap objectForKey:@"values"];
    if ([committedValues isKindOfClass:[NSNull class]]) {
        return @[];
    }
    // else
    NSMutableSet *deletedValues = [committedValues mutableCopy];
    [deletedValues minusSet:self.values];
    return [deletedValues allObjects];
}

- (NSArray *)createEditEventsForParticipant:(WMParticipant *)participant
{
    NSArray *addedValues = self.woundMeasurementValuesAdded;
    NSArray *deletedValues = self.woundMeasurementValuesRemoved;
    NSMutableArray *events = [NSMutableArray array];
    for (WMWoundMeasurementValue *value in addedValues) {
        [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeAdd
                                                         title:value.woundMeasurement.title
                                                     valueFrom:nil
                                                       valueTo:(value.value == nil ? value.title:value.value)
                                                          type:nil
                                                   participant:participant
                                                        create:YES
                                          managedObjectContext:self.managedObjectContext]];
        DLog(@"Created add event %@", value.woundMeasurement.title);
    }
    for (WMWoundMeasurementValue *value in deletedValues) {
        [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeDelete
                                                         title:value.title
                                                     valueFrom:nil
                                                       valueTo:nil
                                                          type:nil
                                                   participant:participant
                                                        create:YES
                                          managedObjectContext:self.managedObjectContext]];
        DLog(@"Created delete event %@", value.title);
    }
    for (WMWoundMeasurementValue *value in [self.managedObjectContext updatedObjects]) {
        if ([value isKindOfClass:[WMWoundMeasurementValue class]]) {
            NSString *oldValue = nil;
            NSString *newValue = nil;
            WMWoundMeasurementValue *woundMeasurementValue = (WMWoundMeasurementValue *)value;
            if (nil != woundMeasurementValue.amountQualifier) {
                NSDictionary *committedValuesMap = [value committedValuesForKeys:@[@"amountQualifier"]];
                oldValue = [[committedValuesMap objectForKey:@"amountQualifier"] valueForKey:@"title"];
                newValue = value.amountQualifier.title;
            } else if (nil != woundMeasurementValue.odor) {
                NSDictionary *committedValuesMap = [value committedValuesForKeys:@[@"odor"]];
                oldValue = [[committedValuesMap objectForKey:@"odor"] valueForKey:@"title"];
                newValue = value.odor.title;
            } else {
                NSDictionary *committedValuesMap = [value committedValuesForKeys:@[@"value"]];
                oldValue = [committedValuesMap objectForKey:@"value"];
                newValue = value.value;
            }
            if (![oldValue isEqual:[NSNull null]] && [oldValue isEqualToString:newValue]) {
                continue;
            }
            // else it changed
            [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeUpdateValue
                                                             title:value.woundMeasurement.title
                                                         valueFrom:oldValue
                                                           valueTo:newValue
                                                              type:nil
                                                       participant:participant
                                                            create:YES
                                              managedObjectContext:self.managedObjectContext]];
            DLog(@"Created event %@->%@", oldValue, newValue);
        }
    }
    return events;
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

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"closedFlagValue",
                                                            @"continueCountValue",
                                                            @"flagsValue",
                                                            @"isClosed",
                                                            @"measurementValueWidth",
                                                            @"measurementValueLength",
                                                            @"measurementValueDepth",
                                                            @"hasInterventionEvents",
                                                            @"woundMeasurementValuesAdded",
                                                            @"woundMeasurementValuesRemoved",
                                                            @"lastWoundMeasurementDate",
                                                            @"dateModifiedExludingMeasurement",
                                                            @"tunnelingValueCount",
                                                            @"underminingValueCount",
                                                            @"valuesFromFetch",
                                                            @"groupValueTypeCode",
                                                            @"title",
                                                            @"value",
                                                            @"placeHolder",
                                                            @"unit",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"objectID",
                                                            @"devices",
                                                            @"hasInterventionEvents",
                                                            @"sortedDeviceValues",
                                                            @"isClosed",
                                                            @"deviceValuesAdded",
                                                            @"deviceValuesRemoved"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMWoundMeasurementGroup attributeNamesNotToSerialize] containsObject:propertyName] || [[WMWoundMeasurementGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundMeasurementGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

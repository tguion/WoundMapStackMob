#import "WMWoundTreatmentGroup.h"
#import "WMPatient.h"
#import "WMWoundTreatmentValue.h"
#import "WMWound.h"
#import "WMWoundTreatment.h"
#import "WMInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

@interface WMWoundTreatmentGroup ()

// Private interface goes here.

@end


@implementation WMWoundTreatmentGroup

+ (WMWoundTreatmentGroup *)woundTreatmentGroupForWound:(WMWound *)wound
{
    WMWoundTreatmentGroup *woundTreatmentGroup = [WMWoundTreatmentGroup MR_createInContext:[wound managedObjectContext]];
    woundTreatmentGroup.wound = wound;
    return woundTreatmentGroup;
}

+ (BOOL)woundTreatmentGroupsHaveHistory:(WMWound *)wound
{
    return [self woundTreatmentGroupsInactiveOrClosedCount:wound] > 0;
}

+ (NSInteger)woundTreatmentGroupsCount:(WMWound *)wound
{
    return [WMWoundTreatmentGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@", wound] inContext:[wound managedObjectContext]];
}

+ (NSInteger)woundTreatmentGroupsInactiveOrClosedCount:(WMWound *)wound
{
    return [WMWoundTreatmentGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND status.activeFlag == NO OR closedFlag == YES", wound] inContext:[wound managedObjectContext]];
}

+ (NSDate *)mostRecentDateModified:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundTreatmentGroup"];
    request.predicate = [NSPredicate predicateWithFormat:@"wound == %@", wound];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMWoundTreatmentGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    return date[@"updatedAt"];
}

+ (NSDate *)lastWoundTreatmentGroupCreated:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSExpression *dateCreatedExpression = [NSExpression expressionForKeyPath:WMWoundTreatmentGroupAttributes.createdAt];
    NSExpressionDescription *dateCreatedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateCreatedExpressionDescription.name = WMWoundTreatmentGroupAttributes.createdAt;
    dateCreatedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateCreatedExpression]];
    dateCreatedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[WMWoundTreatmentGroup entityName]];
    request.predicate = [NSPredicate predicateWithFormat:@"wound.patient == %@", patient];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateCreatedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMWoundTreatmentGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    return date[WMWoundTreatmentGroupAttributes.createdAt];
}

+ (WMWoundTreatmentGroup *)activeWoundTreatmentGroupForWound:(WMWound *)wound
{
    return [WMWoundTreatmentGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND status.activeFlag == YES AND closedFlag == NO", wound]
                                                   sortedBy:WMWoundTreatmentGroupAttributes.createdAt
                                                  ascending:NO
                                                  inContext:[wound managedObjectContext]];
}

+ (NSInteger)closeWoundTreatmentGroupsCreatedBefore:(NSDate *)date
                                              wound:(WMWound *)wound;
{
    NSArray *array = [WMWoundTreatmentGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND closedFlag == NO AND createdAt < %@", wound, date] inContext:[wound managedObjectContext]];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

- (BOOL)hasWoundTreatmentValuesForWoundTreatmentAndChildren:(WMWoundTreatment *)woundTreatment
{
    NSMutableSet *woundTreatments = [[NSMutableSet alloc] initWithCapacity:16];
    [woundTreatment aggregateWoundTreatments:woundTreatments];
    NSMutableSet *woundTreatmentsForValues = [[self.values valueForKeyPath:@"woundTreatment"] mutableCopy];
    return [woundTreatmentsForValues intersectsSet:woundTreatments];
}

- (WMWoundTreatmentValue *)woundTreatmentValueForWoundTreatment:(WMWoundTreatment *)woundTreatment
                                                         create:(BOOL)create
                                                          value:(id)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (woundTreatment) {
        NSParameterAssert([woundTreatment managedObjectContext] == managedObjectContext);
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND woundTreatment == %@", self, woundTreatment];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, [NSPredicate predicateWithFormat:@"value == %@", value], nil]];
    }
    WMWoundTreatmentValue *woundTreatmentValue = [WMWoundTreatmentValue MR_findFirstWithPredicate:predicate inContext:[self managedObjectContext]];
    if (create && nil == woundTreatmentValue) {
        woundTreatmentValue = [WMWoundTreatmentValue MR_createInContext:managedObjectContext];
        woundTreatmentValue.woundTreatment = woundTreatment;
        woundTreatmentValue.value = value;
        woundTreatmentValue.title = woundTreatment.title;
        [self addValuesObject:woundTreatmentValue];
    }
    return woundTreatmentValue;
}

- (void)removeWoundTreatmentValuesForParentWoundTreatment:(WMWoundTreatment *)woundTreatment
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"woundTreatment.parentTreatment == %@", woundTreatment];
    NSArray *values = [[self.values allObjects] filteredArrayUsingPredicate:predicate];
    for (WMWoundTreatmentValue *value in values) {
        [self removeValuesObject:value];
        [managedObjectContext deleteObject:value];
    }
}

- (WMWoundTreatment *)woundTreatmentForParentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment sectionTitle:(NSString *)sectionTitle
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSArray *woundTreatments = (parentWoundTreatment == nil ? [WMWoundTreatment sortedRootWoundTreatments:managedObjectContext]:[parentWoundTreatment.childrenTreatments allObjects]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"woundTreatment IN (%@) AND woundTreatment.sectionTitle == %@", woundTreatments, sectionTitle];
    NSArray *values = [[self.values allObjects] filteredArrayUsingPredicate:predicate];
    return [[values lastObject] woundTreatment];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    // initial status
    self.status = [WMInterventionStatus initialInterventionStatus:[self managedObjectContext]];
}

- (BOOL)isClosed
{
    return self.closedFlagValue;
}

- (NSInteger)valuesCountForWoundTreatment:(WMWoundTreatment *)woundTreatment
{
    NSMutableSet *woundTreatments = [[NSMutableSet alloc] initWithCapacity:32];
    [woundTreatment aggregateWoundTreatments:woundTreatments];
    NSMutableSet *woundTreatmentsForValues = [[self.values valueForKeyPath:@"woundTreatment"] mutableCopy];
    [woundTreatmentsForValues intersectSet:woundTreatments];
    return [woundTreatmentsForValues count];
}

#pragma mark - Normalization

- (NSArray *)woundTreatmentValuesForParentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment
{
    return [WMWoundTreatmentValue MR_findAllSortedBy:@"woundTreatment.sortRank" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND woundTreatment.parentTreatment == %@", self, parentWoundTreatment] inContext:[self managedObjectContext]];
}

- (NSDecimalNumber *)totalPercentageAmount:(WMWoundTreatment *)parentWoundTreatment
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
    NSArray *values = [self woundTreatmentValuesForParentWoundTreatment:parentWoundTreatment];
    NSDecimalNumber *amount = [NSDecimalNumber zero];
    for (WMWoundTreatmentValue *value in values) {
        amount = [amount decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:value.value]];
    }
    amount = [amount decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return amount;
}

- (void)normalizeInputsForParentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment
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
    NSDecimalNumber *sum = [self totalPercentageAmount:parentWoundTreatment];
    if ([sum floatValue] == 0.0) {
        return;
    }
    // else
    NSDecimalNumber *multiplier = [[NSDecimalNumber decimalNumberWithString:@"100.0"] decimalNumberByDividingBy:sum];
    NSArray *values = [self woundTreatmentValuesForParentWoundTreatment:parentWoundTreatment];
    for (WMWoundTreatmentValue *value in values) {
        NSDecimalNumber *number = [[NSDecimalNumber decimalNumberWithString:value.value] decimalNumberByMultiplyingBy:multiplier];
        number = [number decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
        value.value = [number stringValue];
    }
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
    WMInterventionEvent *event = [WMInterventionEvent interventionEventForWoundTreatmentGroup:self
                                                                                   changeType:changeType
                                                                                        title:title
                                                                                    valueFrom:valueFrom
                                                                                      valueTo:valueTo
                                                                                         type:type
                                                                                  participant:participant
                                                                                       create:create
                                                                         managedObjectContext:managedObjectContext];
    event.treatmentGroup = self;
    return event;
}

- (NSArray *)woundTreatmentValuesAdded
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

- (NSArray *)woundTreatmentValuesRemoved
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
    NSArray *addedValues = self.woundTreatmentValuesAdded;
    NSArray *deletedValues = self.woundTreatmentValuesRemoved;
    NSMutableArray *events = [NSMutableArray array];
    for (WMWoundTreatmentValue *value in addedValues) {
        [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeAdd
                                                         title:value.woundTreatment.title
                                                     valueFrom:nil
                                                       valueTo:value.value
                                                          type:nil
                                                   participant:participant
                                                        create:YES
                                          managedObjectContext:self.managedObjectContext]];
        DLog(@"Created add event %@", value.woundTreatment.title);
    }
    for (WMWoundTreatmentValue *value in deletedValues) {
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
    for (WMWoundTreatmentValue *value in [self.managedObjectContext updatedObjects]) {
        if ([value isKindOfClass:[WMWoundTreatmentValue class]]) {
            NSDictionary *committedValuesMap = [self committedValuesForKeys:@[@"values"]];
            NSString *oldValue = [committedValuesMap objectForKey:@"value"];
            NSString *newValue = value.value;
            if ([newValue isKindOfClass:[NSString class]] && [newValue isEqualToString:oldValue]) {
                continue;
            }
            // else it changed
            [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeUpdateValue
                                                             title:value.woundTreatment.title
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

- (BOOL)hasInterventionEvents
{
    return [self.interventionEvents count] > 0;
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
                                                            @"groupValueTypeCode",
                                                            @"title",
                                                            @"value",
                                                            @"placeHolder",
                                                            @"unit",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"objectID",
                                                            @"interventionEvents",
                                                            @"isClosed",
                                                            @"hasInterventionEvents",
                                                            @"woundTreatmentValuesAdded",
                                                            @"woundTreatmentValuesRemoved"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMWoundTreatmentGroupRelationships.interventionEvents,
                                                            WMWoundTreatmentGroupRelationships.values]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMWoundTreatmentGroup attributeNamesNotToSerialize] containsObject:propertyName] || [[WMWoundTreatmentGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundTreatmentGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

#pragma mark - AssessmentGroup

- (GroupValueTypeCode)groupValueTypeCode
{
    return GroupValueTypeCodeSelect;
}

- (NSString *)title
{
    return nil;
}

- (void)setTitle:(NSString *)title
{
    
}

- (NSString *)placeHolder
{
    return nil;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    
}

- (NSString *)unit
{
    return nil;
}

- (void)setUnit:(NSString *)unit
{
}

- (id)value
{
    return nil;
}

- (void)setValue:(id)value
{
}

- (NSArray *)optionsArray
{
    return [NSArray array];
}

- (NSArray *)secondaryOptionsArray
{
    return self.optionsArray;
}

@end

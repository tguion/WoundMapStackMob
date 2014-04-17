#import "WMCarePlanGroup.h"
#import "WMPatient.h"
#import "WMCarePlanGroup.h"
#import "WMCarePlanCategory.h"
#import "WMCarePlanValue.h"
#import "WMInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

@interface WMCarePlanGroup ()

// Private interface goes here.

@end


@implementation WMCarePlanGroup

+ (WMCarePlanGroup *)activeCarePlanGroup:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    return [WMCarePlanGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND status.activeFlag == YES AND closedFlag == NO", patient]
                                             sortedBy:@"updatedAt"
                                            ascending:NO
                                            inContext:managedObjectContext];
}

+ (WMCarePlanGroup *)mostRecentOrActiveCarePlanGroup:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMCarePlanGroup *carePlanGroup = [self activeCarePlanGroup:patient];
    if (nil == carePlanGroup) {
        carePlanGroup = [WMCarePlanGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                                          sortedBy:@"updatedAt"
                                                         ascending:NO
                                                         inContext:managedObjectContext];
    }
    return carePlanGroup;
}

+ (NSDate *)mostRecentOrActiveCarePlanGroupDateModified:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMCarePlanGroup"];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMCarePlanGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    return date[@"updatedAt"];
}

+ (NSInteger)closeCarePlanGroupsCreatedBefore:(NSDate *)date
                                      patient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSArray *array = [WMCarePlanGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND createdAt < %@", patient, date]
                                                    inContext:managedObjectContext];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (NSSet *)carePlanValuesForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup
{
    return [NSSet setWithArray:[WMCarePlanGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"group == %@", carePlanGroup] inContext:[carePlanGroup managedObjectContext]]];
}

+ (BOOL)carePlanGroupsHaveHistory:(WMPatient *)patient
{
    return [self carePlanGroupsCount:patient] > 1;
}

+ (NSInteger)carePlanGroupsCount:(WMPatient *)patient
{
    return [WMCarePlanGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:[patient managedObjectContext]];
}

+ (NSArray *)sortedCarePlanGroups:(WMPatient *)patient
{
    return [WMCarePlanGroup MR_findAllSortedBy:@"createdAt"
                                     ascending:NO
                                 withPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                     inContext:[patient managedObjectContext]];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    // initial status
    self.status = [WMInterventionStatus initialInterventionStatus:[self managedObjectContext]];
}

- (NSArray *)sortedCarePlanValues
{
    return [[self.values allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"item.category.sortRank" ascending:YES],
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"item.sortRank" ascending:YES],
                                                                  nil]];
}

- (BOOL)isClosed
{
    return self.closedFlagValue;
}

- (BOOL)hasInterventionEvents
{
    return [self.interventionEvents count] > 0;
}

- (WMCarePlanValue *)carePlanValueForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory
                                               create:(BOOL)create
                                                value:(NSString *)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (nil != carePlanCategory) {
        NSParameterAssert(managedObjectContext == [carePlanCategory managedObjectContext]);
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND category == %@", self, carePlanCategory];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, [NSPredicate predicateWithFormat:@"value == %@", value], nil]];
    }
    WMCarePlanValue *carePlanValue = [WMCarePlanValue MR_findFirstWithPredicate:predicate inContext:managedObjectContext];
    if (create && nil == carePlanValue) {
        carePlanValue = [WMCarePlanValue MR_createInContext:managedObjectContext];
        carePlanValue.category = carePlanCategory;
        carePlanValue.value = value;
        carePlanValue.title = carePlanCategory.title;
        [self addValuesObject:carePlanValue];
    }
    return carePlanValue;
}

- (WMCarePlanCategory *)carePlanCategoryForParentCategory:(WMCarePlanCategory *)parentCategory
{
    NSArray *categories = [parentCategory.subcategories allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category IN (%@)", categories];
    NSArray *values = [[self.values allObjects] filteredArrayUsingPredicate:predicate];
    return [[values lastObject] valueForKey:@"category"];
}

- (BOOL)hasValueForCategoryOrDescendants:(WMCarePlanCategory *)carePlanCategory
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:32];
    [carePlanCategory aggregateSubcategories:set];
    NSMutableSet *categories = [[self.values valueForKeyPath:@"category"] mutableCopy];
    return [set intersectsSet:categories];
}

- (void)removeCarePlanValuesForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", carePlanCategory];
    NSArray *values = [[self.values allObjects] filteredArrayUsingPredicate:predicate];
    for (WMCarePlanValue *value in values) {
        [self removeValuesObject:value];
        [managedObjectContext deleteObject:value];
    }
}

- (NSInteger)valuesCountForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:32];
    [carePlanCategory aggregateSubcategories:set];
    // do not rely on the cache self.values toMany relationship - fetch fresh from store
    NSMutableSet *categories = [[[WMCarePlanGroup carePlanValuesForCarePlanGroup:self] valueForKeyPath:@"category"] mutableCopy];
    [set intersectSet:categories];
    return [set count];
}

// refetch all data from datastore
- (void)refreshData
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSSet *values = [WMCarePlanGroup carePlanValuesForCarePlanGroup:self];
    for (WMCarePlanValue *value in values) {
        [managedObjectContext refreshObject:value mergeChanges:value.hasChanges];
    }
    NSSet *carePlanCategories = [WMCarePlanCategory carePlanCategories:managedObjectContext];
    for (WMCarePlanCategory *category in carePlanCategories) {
        [managedObjectContext refreshObject:category mergeChanges:category.hasChanges];
    }
}

#pragma mark - Events

- (WMInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                           path:(NSString *)path
                                                          title:(NSString *)title
                                                      valueFrom:(id)valueFrom
                                                        valueTo:(id)valueTo
                                                           type:(WMInterventionEventType *)type
                                                    participant:(WMParticipant *)participant
                                                         create:(BOOL)create
                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMInterventionEvent *event = [WMInterventionEvent interventionEventForCarePlanGroup:self
                                                                             changeType:changeType
                                                                                   path:path
                                                                                  title:title
                                                                              valueFrom:valueFrom
                                                                                valueTo:valueTo
                                                                                   type:type
                                                                            participant:participant
                                                                                 create:create
                                                                   managedObjectContext:managedObjectContext];
    return event;
}

- (NSArray *)carePlanValuesAdded
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

- (NSArray *)carePlanValuesRemoved
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
    NSArray *addedValues = self.carePlanValuesAdded;
    NSArray *deletedValues = self.carePlanValuesRemoved;
    NSMutableArray *events = [NSMutableArray array];
    for (WMCarePlanValue *carePlanValue in addedValues) {
        NSString *title = carePlanValue.category.title;
        [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeAdd
                                                          path:carePlanValue.pathToValue
                                                         title:title
                                                     valueFrom:nil
                                                       valueTo:carePlanValue.value
                                                          type:nil
                                                   participant:participant
                                                        create:YES
                                          managedObjectContext:self.managedObjectContext]];
        DLog(@"Created add event %@", title);
    }
    for (WMCarePlanValue *carePlanValue in deletedValues) {
        [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeDelete
                                                          path:carePlanValue.pathToValue
                                                         title:carePlanValue.title
                                                     valueFrom:nil
                                                       valueTo:nil
                                                          type:nil
                                                   participant:participant
                                                        create:YES
                                          managedObjectContext:self.managedObjectContext]];
        DLog(@"Created delete event %@", carePlanValue.title);
    }
    for (WMCarePlanValue *carePlanValue in [self.managedObjectContext updatedObjects]) {
        if ([carePlanValue isKindOfClass:[WMCarePlanValue class]]) {
            NSDictionary *committedValuesMap = [carePlanValue committedValuesForKeys:@[@"value"]];
            NSString *oldValue = [committedValuesMap objectForKey:@"value"];
            NSString *newValue = carePlanValue.value;
            if ([oldValue isEqualToString:newValue]) {
                continue;
            }
            // else it changed
            NSString *title = carePlanValue.category.title;
            [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeUpdateValue
                                                              path:carePlanValue.pathToValue
                                                             title:title
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

- (void)incrementContinueCount
{
    self.continueCount = @([self.continueCount intValue] + 1);
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
                                                            @"unit",
                                                            @"value",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"interventionEvents",
                                                            @"hasInterventionEvents",
                                                            @"sortedCarePlanValues",
                                                            @"isClosed",
                                                            @"carePlanValuesAdded",
                                                            @"carePlanValuesRemoved"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMCarePlanGroupRelationships.interventionEvents,
                                                            WMCarePlanGroupRelationships.values]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMCarePlanGroup attributeNamesNotToSerialize] containsObject:propertyName] || [[WMCarePlanGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMCarePlanGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

#pragma mark - AssessmentGroup

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

- (GroupValueTypeCode)groupValueTypeCode
{
    return GroupValueTypeCodeSelect;
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

#import "WMNutritionGroup.h"
#import "WMNutritionItem.h"
#import "WMNutritionValue.h"
#import "WMPatient.h"
#import "WMInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

@interface WMNutritionGroup ()

// Private interface goes here.

@end


@implementation WMNutritionGroup

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    // initial status
    self.status = [WMInterventionStatus initialInterventionStatus:[self managedObjectContext]];
}

+ (WMNutritionGroup *)activeNutritionGroup:(WMPatient *)patient
{
    return [WMNutritionGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO", patient]
                                               sortedBy:@"updatedAt"
                                              ascending:NO
                                              inContext:[patient managedObjectContext]];
}

+ (WMNutritionGroup *)mostRecentOrActiveNutritionGroup:(WMPatient *)patient
{
    WMNutritionGroup *nutritionGroup = [self activeNutritionGroup:patient];
    if (nil == nutritionGroup) {
        nutritionGroup = [WMNutritionGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                                            sortedBy:@"updatedAt"
                                                           ascending:NO
                                                           inContext:[patient managedObjectContext]];
    }
    return nutritionGroup;
}

+ (NSDate *)mostRecentOrActiveNutritionGroupDateModified:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMNutritionGroup"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMNutritionGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    if ([date count] == 0)
        return nil;
    // else
    return date[@"updatedAt"];
}

+ (WMNutritionGroup *)nutritionGroupForPatient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMNutritionGroup *nutritionGroup = [WMNutritionGroup MR_createInContext:managedObjectContext];
    nutritionGroup.patient = patient;
    nutritionGroup.status = [WMInterventionStatus initialInterventionStatus:managedObjectContext];
    return nutritionGroup;
}

+ (NSInteger)closeNutritionGroupsCreatedBefore:(NSDate *)date
                                       patient:(WMPatient *)patient
{
    NSArray *array = [WMNutritionGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND createdAt < %@", patient, date] inContext:[patient managedObjectContext]];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}


- (WMNutritionValue *)nutritionValueForItem:(WMNutritionItem *)item
                                     create:(BOOL)create
                                      value:(NSString *)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSParameterAssert(managedObjectContext == [item managedObjectContext]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", WMNutritionValueRelationships.nutritionGroup, self, WMNutritionValueRelationships.item, item];
    if (value) {
        predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@ AND %K == %@", WMNutritionValueRelationships.nutritionGroup, self,
                     WMNutritionValueRelationships.item, item,
                     WMNutritionValueAttributes.value, value];
    }
    WMNutritionValue *nutritionValue = [WMNutritionValue MR_findFirstWithPredicate:predicate inContext:managedObjectContext];
    if (create && nil == nutritionValue) {
        nutritionValue = [WMNutritionValue MR_createInContext:managedObjectContext];
        nutritionValue.nutritionGroup = self;
        nutritionValue.item = item;
        nutritionValue.value = value;
        nutritionValue.value = value;
        [self addValuesObject:nutritionValue];
    }
    return nutritionValue;
}

- (NSArray *)sortedValues
{
    return [WMNutritionValue MR_findAllSortedBy:@"item.sortRank"
                                      ascending:YES
                                  withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMNutritionValueRelationships.nutritionGroup, self]
                                      inContext:[self managedObjectContext]];
}

+ (NSArray *)sortedNutritionGroups:(WMPatient *)patient
{
    return [WMNutritionGroup MR_findAllSortedBy:WMNutritionGroupAttributes.createdAt ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMNutritionGroupRelationships.patient, patient] inContext:[patient managedObjectContext]];
}

+ (NSInteger)nutritionGroupsCount:(WMPatient *)patient
{
    return [WMNutritionGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMNutritionGroupRelationships.patient, patient] inContext:[patient managedObjectContext]];
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
    WMInterventionEvent *event = [WMInterventionEvent interventionEventForNutritionGroup:self
                                                                               changeType:changeType
                                                                                    title:title
                                                                                valueFrom:valueFrom
                                                                                  valueTo:valueTo
                                                                                     type:type
                                                                              participant:participant
                                                                                   create:create
                                                                     managedObjectContext:managedObjectContext];
    event.nutritionGroup = self;
    return event;
}

- (NSArray *)nutritionValuesAdded
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

- (NSArray *)nutritionValuesRemoved
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
    NSArray *addedValues = self.nutritionValuesAdded;
    NSArray *deletedValues = self.nutritionValuesRemoved;
    NSMutableArray *events = [NSMutableArray array];
    for (WMNutritionValue *nutritionValue in addedValues) {
        [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeAdd
                                                         title:nutritionValue.title
                                                     valueFrom:nil
                                                       valueTo:nutritionValue.value
                                                          type:nil
                                                   participant:participant
                                                        create:YES
                                          managedObjectContext:self.managedObjectContext]];
        DLog(@"Created add event %@", nutritionValue.title);
    }
    for (WMNutritionValue *nutritionValue in deletedValues) {
        [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeDelete
                                                         title:nutritionValue.title
                                                     valueFrom:nil
                                                       valueTo:nil
                                                          type:nil
                                                   participant:participant
                                                        create:YES
                                          managedObjectContext:self.managedObjectContext]];
        DLog(@"Created delete event %@", nutritionValue.title);
    }
    for (WMNutritionValue *nutritionValue in [self.managedObjectContext updatedObjects]) {
        if ([nutritionValue isKindOfClass:[WMNutritionValue class]]) {
            NSDictionary *committedValuesMap = [nutritionValue committedValuesForKeys:@[@"values"]];
            NSString *oldValue = [committedValuesMap objectForKey:@"value"];
            NSString *newValue = nutritionValue.value;
            if (![oldValue isKindOfClass:[NSString class]] && newValue == nil) {
                continue;
            }
            if ([oldValue isEqualToString:newValue]) {
                continue;
            }
            // else it changed
            [events addObject:[self interventionEventForChangeType:InterventionEventChangeTypeUpdateValue
                                                             title:nutritionValue.item.title
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

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return self.patient;
}

- (BOOL)requireUpdatesFromCloud
{
    return YES;
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
                                                            @"snomedCIDValue",
                                                            @"nutritionValuesAdded",
                                                            @"nutritionValuesRemoved",
                                                            @"sortedValues",
                                                            @"objectID",
                                                            @"requireUpdatesFromCloud",
                                                            @"aggregator"]];
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
    if ([[WMNutritionGroup attributeNamesNotToSerialize] containsObject:propertyName] || [[WMNutritionGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMNutritionGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

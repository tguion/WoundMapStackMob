#import "WMPsychoSocialGroup.h"
#import "WMPatient.h"
#import "WMPsychoSocialItem.h"
#import "WMPsychoSocialValue.h"
#import "WMPsychoSocialIntEvent.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

@interface WMPsychoSocialGroup ()

// Private interface goes here.

@end


@implementation WMPsychoSocialGroup

+ (BOOL)psychoSocialGroupsHaveHistory:(WMPatient *)patient
{
    return [self psychoSocialGroupsCount:patient] > 1;
}

+ (NSInteger)psychoSocialGroupsCount:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

+ (NSSet *)psychoSocialValuesForPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup
{
    return [NSSet setWithArray:[WMPsychoSocialValue MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"group == %@", psychoSocialGroup] inContext:[psychoSocialGroup managedObjectContext]]];
}

+ (WMPsychoSocialGroup *)activePsychoSocialGroup:(WMPatient *)patient
{
    return [WMPsychoSocialGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND status.activeFlag == YES AND closedFlag == NO", patient]
                                                 sortedBy:@"updatedAt"
                                                ascending:NO
                                                inContext:[patient managedObjectContext]];
}

+ (WMPsychoSocialGroup *)mostRecentOrActivePsychosocialGroup:(WMPatient *)patient
{
    WMPsychoSocialGroup *psychoSocialGroup = [self activePsychoSocialGroup:patient];
    if (nil == psychoSocialGroup) {
        psychoSocialGroup = [WMPsychoSocialGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                                                  sortedBy:@"updatedAt"
                                                                 ascending:NO
                                                                 inContext:[patient managedObjectContext]];
    }
    return psychoSocialGroup;
}

+ (NSInteger)closePsychoSocialGroupsCreatedBefore:(NSDate *)date
                                          patient:(WMPatient *)patient
{
    NSArray *array = [WMPsychoSocialGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND dateCreated < %@", patient, date] inContext:[patient managedObjectContext]];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (NSDate *)mostRecentOrActivePsychoSocialGroupDateModified:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMPsychoSocialGroup"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMPsychoSocialGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    if ([date count] == 0)
        return nil;
    // else
    return date[@"updatedAt"];
}

+ (NSArray *)sortedPsychoSocialGroups:(WMPatient *)patient
{
    return [WMPsychoSocialGroup MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:[patient managedObjectContext]];
}

+ (NSArray *)sortedPsychoSocialValuesForGroup:(WMPsychoSocialGroup *)group parentPsychoSocialItem:(WMPsychoSocialItem *)parentItem
{
    NSManagedObjectContext *managedObjectContext = [group managedObjectContext];
    if (parentItem) {
        NSParameterAssert([parentItem managedObjectContext] == managedObjectContext);
    }
    return [WMPsychoSocialValue MR_findAllSortedBy:@"psychoSocialItem.sortRank" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND psychoSocialItem.parentItem == %@", group, parentItem] inContext:managedObjectContext];
}

+ (NSArray *)sortedPsychoSocialValuesForGroup:(WMPsychoSocialGroup *)group psychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem
{
    NSManagedObjectContext *managedObjectContext = [group managedObjectContext];
    if (psychoSocialItem) {
        NSParameterAssert([psychoSocialItem managedObjectContext] == managedObjectContext);
    }
    return [WMPsychoSocialValue MR_findAllSortedBy:@"psychoSocialItem.sortRank" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND psychoSocialItem == %@", group, psychoSocialItem] inContext:managedObjectContext];
}

+ (BOOL)hasPsychoSocialValueForChildrenOfParentItem:(WMPsychoSocialGroup *)psychoSocialGroup
                             parentPsychoSocialItem:(WMPsychoSocialItem *)parentPsychoSocialItem
{
    NSManagedObjectContext *managedObjectContext = [psychoSocialGroup managedObjectContext];
    if (parentPsychoSocialItem) {
        NSParameterAssert([parentPsychoSocialItem managedObjectContext] == managedObjectContext);
    }
    return [WMPsychoSocialValue MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND (psychoSocialItem.parentItem == %@ OR psychoSocialItem.parentItem.parentItem == %@)", psychoSocialGroup, parentPsychoSocialItem, parentPsychoSocialItem]
                                                      inContext:managedObjectContext] > 0;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    // initial status
    self.status = [WMInterventionStatus initialInterventionStatus:[self managedObjectContext]];
}

- (BOOL)hasInterventionEvents
{
    return [self.interventionEvents count] > 0;
}

- (WMPsychoSocialValue *)psychoSocialValueForPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup
                                              psychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem
                                                        create:(BOOL)create
                                                         value:(NSString *)value
{
    NSManagedObjectContext *managedObjectContext = [psychoSocialGroup managedObjectContext];
    if (psychoSocialItem) {
        NSParameterAssert([psychoSocialItem managedObjectContext] == managedObjectContext);
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND psychoSocialItem == %@", psychoSocialGroup, psychoSocialItem];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, [NSPredicate predicateWithFormat:@"value == %@", value], nil]];
    }
    WMPsychoSocialValue *psychoSocialValue = [WMPsychoSocialValue MR_findFirstWithPredicate:predicate inContext:managedObjectContext];
    if (create && nil == psychoSocialValue) {
        psychoSocialValue = [WMPsychoSocialValue MR_createInContext:managedObjectContext];
        psychoSocialValue.group = psychoSocialGroup;
        psychoSocialValue.psychoSocialItem = psychoSocialItem;
        psychoSocialValue.value = value;
        psychoSocialValue.title = psychoSocialItem.title;
        [self addValuesObject:psychoSocialValue];
    }
    return psychoSocialValue;
}

- (WMPsychoSocialValue *)psychoSocialValueForParentItem:(WMPsychoSocialItem *)parentItem
{
    return [WMPsychoSocialValue MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND psychoSocialItem.parentItem == %@", self, parentItem] inContext:[self managedObjectContext]];
}

- (void)removePsychoSocialValuesForPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"psychoSocialItem == %@", psychoSocialItem];
    NSArray *values = [[self.values allObjects] filteredArrayUsingPredicate:predicate];
    for (WMPsychoSocialValue *value in values) {
        [self removeValuesObject:value];
        [managedObjectContext deleteObject:value];
    }
}

- (NSInteger)valuesCountForPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:32];
    [psychoSocialItem aggregatePsychoSocialItems:set];
    // do not rely on the cache self.values toMany relationship - fetch fresh from store
    NSMutableSet *psychoSocialItems = [[[WMPsychoSocialGroup psychoSocialValuesForPsychoSocialGroup:self] valueForKeyPath:@"psychoSocialItem"] mutableCopy];
    [psychoSocialItems unionSet:[self.values valueForKeyPath:@"psychoSocialItem"]];
    [set intersectSet:psychoSocialItems];
    return [set count];
}

- (NSInteger)subitemValueCountForPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem
{
    NSInteger count = 0;
    for (WMPsychoSocialItem *subitem in psychoSocialItem.subitems) {
        WMPsychoSocialValue *psychoSocialValue = [self psychoSocialValueForPsychoSocialGroup:self
                                                                            psychoSocialItem:subitem
                                                                                      create:NO
                                                                                       value:nil];
        if (nil != psychoSocialValue) {
            ++count;
        }
        if ([subitem.subitems count] > 0) {
            count += [self subitemValueCountForPsychoSocialItem:subitem];
        }
    }
    return count;
}

- (NSInteger)updatedScoreForPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem
{
    NSInteger score = 0;
    for (WMPsychoSocialItem *subitem in psychoSocialItem.subitems) {
        WMPsychoSocialValue *psychoSocialValue = [self psychoSocialValueForPsychoSocialGroup:self
                                                                            psychoSocialItem:subitem
                                                                                      create:NO
                                                                                       value:nil];
        if (nil != psychoSocialValue) {
            score += [psychoSocialValue.psychoSocialItem.score integerValue];
        }
        if ([subitem.subitems count] > 0) {
            score += [self updatedScoreForPsychoSocialItem:subitem];
        }
    }
    return score;
}

#pragma mark - Events

- (WMPsychoSocialIntEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                      path:(NSString *)path
                                                     title:(NSString *)title
                                                 valueFrom:(id)valueFrom
                                                   valueTo:(id)valueTo
                                                      type:(WMInterventionEventType *)type
                                               participant:(WMParticipant *)participant
                                                    create:(BOOL)create
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMPsychoSocialIntEvent *event = [WMPsychoSocialIntEvent psychoSocialInterventionEventForPsychoSocialGroup:self
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

- (void)createEditEventsForParticipant:(WMParticipant *)participant
{
    NSDictionary *committedValuesMap = [self committedValuesForKeys:[NSArray arrayWithObjects:@"values", nil]];
    NSSet *committedValues = [committedValuesMap objectForKey:@"values"];
    if ([committedValues isKindOfClass:[NSNull class]]) {
        return;
    }
    // else
    NSMutableSet *addedValues = [self.values mutableCopy];
    [addedValues minusSet:committedValues];
    NSMutableSet *deletedValues = [committedValues mutableCopy];
    [deletedValues minusSet:self.values];
    for (WMPsychoSocialValue *psychoSocialValue in addedValues) {
        NSString *title = psychoSocialValue.psychoSocialItem.title;
        [self interventionEventForChangeType:InterventionEventChangeTypeAdd
                                        path:psychoSocialValue.pathToValue
                                       title:title
                                   valueFrom:nil
                                     valueTo:psychoSocialValue.value
                                        type:nil
                                 participant:participant
                                      create:YES
                        managedObjectContext:self.managedObjectContext];
        DLog(@"Created add event %@", title);
    }
    for (WMPsychoSocialValue *psychoSocialValue in deletedValues) {
        [self interventionEventForChangeType:InterventionEventChangeTypeDelete
                                        path:psychoSocialValue.pathToValue
                                       title:psychoSocialValue.title
                                   valueFrom:nil
                                     valueTo:nil
                                        type:nil
                                 participant:participant
                                      create:YES
                        managedObjectContext:self.managedObjectContext];
        DLog(@"Created delete event %@", psychoSocialValue.title);
    }
    for (WMPsychoSocialValue *psychoSocialValue in [self.managedObjectContext updatedObjects]) {
        if ([psychoSocialValue isKindOfClass:[WMPsychoSocialValue class]]) {
            committedValuesMap = [psychoSocialValue committedValuesForKeys:[NSArray arrayWithObjects:@"value", nil]];
            NSString *oldValue = [committedValuesMap objectForKey:@"value"];
            NSString *newValue = psychoSocialValue.value;
            if ([oldValue isEqualToString:newValue]) {
                continue;
            }
            // else it changed
            NSString *title = psychoSocialValue.psychoSocialItem.title;
            [self interventionEventForChangeType:InterventionEventChangeTypeUpdateValue
                                            path:psychoSocialValue.pathToValue
                                           title:title
                                       valueFrom:oldValue
                                         valueTo:newValue
                                            type:nil
                                     participant:participant
                                          create:YES
                            managedObjectContext:self.managedObjectContext];
            DLog(@"Created event %@->%@", oldValue, newValue);
        }
    }
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

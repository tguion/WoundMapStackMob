#import "WMSkinAssessmentGroup.h"
#import "WMPatient.h"
#import "WMSkinAssessment.h"
#import "WMSkinAssessmentValue.h"
#import "WMSkinAssessmentIntEvent.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

@interface WMSkinAssessmentGroup ()

// Private interface goes here.

@end


@implementation WMSkinAssessmentGroup

+ (WMSkinAssessmentGroup *)activeSkinAssessmentGroup:(WMPatient *)patient
{
    return [WMSkinAssessmentGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND status.activeFlag == YES AND closedFlag == NO", patient] sortedBy:@"updatedAt" ascending:NO inContext:[patient managedObjectContext]];
}

+ (NSInteger)closeSkinAssessmentGroupsCreatedBefore:(NSDate *)date
                                            patient:(WMPatient *)patient
{
    NSArray *array = [WMSkinAssessmentGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND createdAt < %@", patient, date] inContext:[patient managedObjectContext]];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (WMSkinAssessmentGroup *)mostRecentOrActiveSkinAssessmentGroup:(WMPatient *)patient
{
    return [WMSkinAssessmentGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] sortedBy:@"updatedAt" ascending:NO inContext:[patient managedObjectContext]];
}

+ (NSDate *)mostRecentOrActiveSkinAssessmentGroupDateModified:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMSkinAssessmentGroup"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMSkinAssessmentGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    return date[@"updatedAt"];
}

+ (BOOL)skinAssessmentGroupsHaveHistory:(WMPatient *)patient
{
    return [self skinAssessmentGroupsCount:patient] > 1;
}

+ (NSInteger)skinAssessmentGroupsCount:(WMPatient *)patient
{
    return [WMSkinAssessmentGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:[patient managedObjectContext]];
}

+ (NSArray *)sortedSkinAssessmentGroups:(WMPatient *)patient
{
    return [WMSkinAssessmentGroup MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:[patient managedObjectContext]];
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

- (WMSkinAssessmentValue *)skinAssessmentValueForSkinAssessment:(WMSkinAssessment *)skinAssessment
                                                         create:(BOOL)create
                                                          value:(id)value
{
    NSManagedObjectContext *managedObjectContext = [skinAssessment managedObjectContext];
    WMSkinAssessmentValue *skinAssessmentValue = [WMSkinAssessmentValue MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND skinAssessment == %@", self, skinAssessment] inContext:managedObjectContext];
    if (create && nil == skinAssessmentValue) {
        skinAssessmentValue = [WMSkinAssessmentValue MR_createInContext:managedObjectContext];
        skinAssessmentValue.skinAssessment = skinAssessment;
        skinAssessmentValue.value = value;
        skinAssessmentValue.title = skinAssessment.title;
        [self addValuesObject:skinAssessmentValue];
    }
    return skinAssessmentValue;
}

- (void)removeSkinAssessmentValuesForCategory:(WMSkinAssessmentCategory *)category
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"skinAssessment.category == %@", category];
    NSArray *values = [[self.values allObjects] filteredArrayUsingPredicate:predicate];
    for (WMSkinAssessmentValue *value in values) {
        [self removeValuesObject:value];
        [managedObjectContext deleteObject:value];
    }
}

- (NSArray *)sortedSkinAssessmentValues
{
    return [[self.values allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"skinAssessment.category.sortRank" ascending:YES],
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"skinAssessment.sortRank" ascending:YES],
                                                                  nil]];
}

- (BOOL)hasValues
{
    return [self.values count] > 0;
}

#pragma mark - Events

- (WMSkinAssessmentIntEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                       title:(NSString *)title
                                                   valueFrom:(id)valueFrom
                                                     valueTo:(id)valueTo
                                                        type:(WMInterventionEventType *)type
                                                 participant:(WMParticipant *)participant
                                                      create:(BOOL)create
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMSkinAssessmentIntEvent *event = [WMSkinAssessmentIntEvent skinAssessmentInterventionEventForSkinAssessmentGroup:self
                                                                                                           changeType:changeType
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
    for (WMSkinAssessmentValue *skinAssessmentValue in addedValues) {
        [self interventionEventForChangeType:InterventionEventChangeTypeAdd
                                       title:skinAssessmentValue.skinAssessment.title
                                   valueFrom:nil
                                     valueTo:skinAssessmentValue.value
                                        type:nil
                                 participant:participant
                                      create:YES
                        managedObjectContext:self.managedObjectContext];
        DLog(@"Created add event %@", skinAssessmentValue.skinAssessment.title);
    }
    for (WMSkinAssessmentValue *skinAssessmentValue in deletedValues) {
        [self interventionEventForChangeType:InterventionEventChangeTypeDelete
                                       title:skinAssessmentValue.title
                                   valueFrom:nil
                                     valueTo:nil
                                        type:nil
                                 participant:participant
                                      create:YES
                        managedObjectContext:self.managedObjectContext];
        DLog(@"Created delete event %@", skinAssessmentValue.title);
    }
    for (WMSkinAssessmentValue *skinAssessmentValue in [self.managedObjectContext updatedObjects]) {
        if ([skinAssessmentValue isKindOfClass:[WMSkinAssessmentValue class]]) {
            committedValuesMap = [skinAssessmentValue committedValuesForKeys:[NSArray arrayWithObjects:@"value", nil]];
            NSString *oldValue = [committedValuesMap objectForKey:@"value"];
            NSString *newValue = skinAssessmentValue.value;
            if ([oldValue isEqualToString:newValue]) {
                continue;
            }
            // else it changed
            [self interventionEventForChangeType:InterventionEventChangeTypeUpdateValue
                                           title:skinAssessmentValue.skinAssessment.title
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

// TODO: consider creating an event to record who/when
- (void)incrementContinueCount
{
    self.continueCount = [NSNumber numberWithInt:([self.continueCount intValue] + 1)];
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

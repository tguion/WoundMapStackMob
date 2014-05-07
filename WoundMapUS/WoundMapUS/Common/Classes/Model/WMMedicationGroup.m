#import "WMMedicationGroup.h"
#import "WMMedication.h"
#import "WMPatient.h"
#import "WMInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"

@interface WMMedicationGroup ()

// Private interface goes here.

@end


@implementation WMMedicationGroup

+ (WMMedicationGroup *)medicationGroupForPatient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMMedicationGroup *medicationGroup = [WMMedicationGroup MR_createInContext:managedObjectContext];
    medicationGroup.patient = patient;
    medicationGroup.status = [WMInterventionStatus initialInterventionStatus:managedObjectContext];
    return medicationGroup;
}

+ (WMMedicationGroup *)activeMedicationGroup:(WMPatient *)patient
{
    return [WMMedicationGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO", patient]
                                               sortedBy:@"updatedAt"
                                              ascending:NO
                                              inContext:[patient managedObjectContext]];
}

+ (WMMedicationGroup *)mostRecentOrActiveMedicationGroup:(WMPatient *)patient
{
    WMMedicationGroup *medicationGroup = [self activeMedicationGroup:patient];
    if (nil == medicationGroup) {
        medicationGroup = [WMMedicationGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                                              sortedBy:@"updatedAt"
                                                             ascending:NO
                                                             inContext:[patient managedObjectContext]];
    }
    return medicationGroup;
}

+ (NSDate *)mostRecentOrActiveMedicationGroupDateModified:(WMPatient *)patient
{
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMMedicationGroup"];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMMedicationGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:[patient managedObjectContext]];
    return date[@"updatedAt"];
}

+ (NSInteger)closeMedicationGroupsCreatedBefore:(NSDate *)date
                                        patient:(WMPatient *)patient
{
    NSArray *array = [WMMedicationGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND createdAt < %@", patient, date]
                                                      inContext:[patient managedObjectContext]];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (BOOL)medicalGroupsHaveHistory:(WMPatient *)patient
{
    return [self medicalGroupsCount:patient] > 1;
}

+ (NSInteger)medicalGroupsCount:(WMPatient *)patient
{
    return [WMMedicationGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:[patient managedObjectContext]];
}

+ (NSArray *)sortedMedicationGroups:(WMPatient *)patient
{
    return [WMMedicationGroup MR_findAllSortedBy:@"createdAt"
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

- (BOOL)isClosed
{
    return self.closedFlagValue;
}

- (BOOL)removeExcludesOtherValues
{
    BOOL result = NO;
    NSArray *medications = [self.medications allObjects];
    for (WMMedication *medication in medications) {
        if (medication.exludesOtherValues) {
            [self removeMedicationsObject:medication];
            result = YES;
        }
    }
    return result;
}

- (NSArray *)sortedMedications
{
    return [[self.medications allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                                                       [NSSortDescriptor sortDescriptorWithKey:@"category.sortRank" ascending:YES],
                                                                       [NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES], nil]];
}

- (NSArray *)medicationsInGroup
{
    return [WMMedication MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"groups CONTAINS (%@)", self] inContext:[self managedObjectContext]];
}

- (BOOL)hasInterventionEvents
{
    return [self.interventionEvents count] > 0;
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
    WMInterventionEvent *event = [WMInterventionEvent interventionEventForMedicationGroup:self
                                                                               changeType:changeType
                                                                                    title:title
                                                                                valueFrom:valueFrom
                                                                                  valueTo:valueTo
                                                                                     type:type
                                                                              participant:participant
                                                                                   create:create
                                                                     managedObjectContext:managedObjectContext];
    event.medicationGroup = self;
    return event;
}

- (NSArray *)medicationsAdded
{
    NSDictionary *committedValuesMap = [self committedValuesForKeys:[NSArray arrayWithObject:@"medications"]];
    NSSet *committedMedications = [committedValuesMap objectForKey:@"medications"];
    NSMutableSet *addedMedications = [self.medications mutableCopy];
    [addedMedications minusSet:committedMedications];
    return [addedMedications allObjects];
}

- (NSArray *)medicationsRemoved
{
    NSDictionary *committedValuesMap = [self committedValuesForKeys:[NSArray arrayWithObject:@"medications"]];
    NSSet *committedMedications = [committedValuesMap objectForKey:@"medications"];
    NSMutableSet *deletedMedications = [committedMedications mutableCopy];
    [deletedMedications minusSet:self.medications];
    return [deletedMedications allObjects];
}

- (NSArray *)createEditEventsForParticipant:(WMParticipant *)participant
{
    // create intervention events before super MCMedicationInterventionEvent
    NSArray *medicationsAdded = self.medicationsAdded;
    NSArray *medicationsRemoved = self.medicationsRemoved;
    NSMutableArray *events = [NSMutableArray array];
    for (WMMedication *medication in medicationsAdded) {
        [events addObject:[WMInterventionEvent interventionEventForMedicationGroup:self
                                                                        changeType:InterventionEventChangeTypeAdd
                                                                             title:medication.title
                                                                         valueFrom:nil
                                                                           valueTo:nil
                                                                              type:nil
                                                                       participant:participant
                                                                            create:YES
                                                              managedObjectContext:self.managedObjectContext]];
        DLog(@"Created add event %@", medication.title);
    }
    for (WMMedication *medication in medicationsRemoved) {
        [events addObject:[WMInterventionEvent interventionEventForMedicationGroup:self
                                                                        changeType:InterventionEventChangeTypeDelete
                                                                             title:medication.title
                                                                         valueFrom:nil
                                                                           valueTo:nil
                                                                              type:nil
                                                                       participant:participant
                                                                            create:YES
                                                              managedObjectContext:self.managedObjectContext]];
        DLog(@"Created delete event %@", medication.title);
    }
    return events;
}

- (void)incrementContinueCount
{
    self.continueCountValue = self.continueCountValue + 1;
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
                                                            @"groupValueTypeCode",
                                                            @"title",
                                                            @"value",
                                                            @"placeHolder",
                                                            @"unit",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"objectID",
                                                            @"hasInterventionEvents",
                                                            @"sortedMedications",
                                                            @"medicationsInGroup",
                                                            @"isClosed",
                                                            @"medicationsAdded",
                                                            @"medicationsRemoved"]];
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
    if ([[WMMedicationGroup attributeNamesNotToSerialize] containsObject:propertyName] || [[WMMedicationGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMMedicationGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
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
    return  self.optionsArray;
}

@end

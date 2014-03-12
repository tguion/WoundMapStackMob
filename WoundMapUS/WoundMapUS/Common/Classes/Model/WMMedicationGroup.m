#import "WMMedicationGroup.h"
#import "WMMedication.h"
#import "WMPatient.h"
#import "WMUtilities.h"

@interface WMMedicationGroup ()

// Private interface goes here.

@end


@implementation WMMedicationGroup

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
    NSArray *array = [WMMedicationGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND dateCreated < %@", patient, date]
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

- (void)incrementContinueCount
{
    self.continueCountValue = self.continueCountValue + 1;
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

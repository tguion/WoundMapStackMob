#import "WMMedicalHistoryGroup.h"
#import "WMMedicalHistoryItem.h"
#import "WMMedicalHistoryValue.h"
#import "WMPatient.h"
#import "WMUtilities.h"

@interface WMMedicalHistoryGroup ()

// Private interface goes here.

@end


@implementation WMMedicalHistoryGroup

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (NSArray *)sortedMedicalHistoryValues
{
    return [[self.values allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"item.sortRank" ascending:YES]]];
}

- (NSInteger)valueCount
{
    return [WMMedicalHistoryValue MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"medicalHistoryGroup == %@ AND value == %d", self, YES] inContext:[self managedObjectContext]];
}

+ (WMMedicalHistoryGroup *)activeMedicalHistoryGroup:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    return  [WMMedicalHistoryGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                                    sortedBy:@"updatedAt"
                                                   ascending:NO
                                                   inContext:managedObjectContext];
}

+ (WMMedicalHistoryGroup *)medicalHistoryGroupForPatient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMMedicalHistoryGroup *medicalHistoryGroup = [WMMedicalHistoryGroup MR_createInContext:managedObjectContext];
    medicalHistoryGroup.patient = patient;
    NSArray *medicalHistoryItems = [WMMedicalHistoryItem sortedMedicalHistoryItems:managedObjectContext];
    for (WMMedicalHistoryItem *medicalHistoryItem in medicalHistoryItems) {
        WMMedicalHistoryValue *medicalHistoryValue = [WMMedicalHistoryValue MR_createInContext:managedObjectContext];
        medicalHistoryValue.medicalHistoryGroup = medicalHistoryGroup;
        medicalHistoryValue.medicalHistoryItem = medicalHistoryItem;
        medicalHistoryValue.value = @"";
    }
    return medicalHistoryGroup;
}

+ (NSSet *)medicalHistoryValuesForMedicalHistoryGroup:(WMMedicalHistoryGroup *)medicalHistoryGroup
{
    return [NSSet setWithArray:[WMMedicalHistoryGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"group == %@", medicalHistoryGroup] inContext:[medicalHistoryGroup managedObjectContext]]];
}

+ (NSInteger)medicalHistoryGroupsCount:(WMPatient *)patient
{
    return [WMMedicalHistoryGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:[patient managedObjectContext]];
}

- (WMMedicalHistoryValue *)medicalHistoryValueForMedicalHistoryItem:(WMMedicalHistoryItem *)medicalHistoryItem
                                                             create:(BOOL)create
                                                              value:(NSString *)value
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (nil != medicalHistoryItem) {
        NSParameterAssert(managedObjectContext == [medicalHistoryItem managedObjectContext]);
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND medicalHistoryItem == %@", self, medicalHistoryItem];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, [NSPredicate predicateWithFormat:@"value == %@", value], nil]];
    }
    WMMedicalHistoryValue *medicalHistoryValue = [WMMedicalHistoryValue MR_findFirstWithPredicate:predicate inContext:managedObjectContext];
    if (create && nil == medicalHistoryValue) {
        medicalHistoryValue = [WMMedicalHistoryValue MR_createInContext:managedObjectContext];
        medicalHistoryValue.value = value;
        [self addValuesObject:medicalHistoryValue];
    }
    return medicalHistoryValue;
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"valueCount",
                                                            @"sortedMedicalHistoryValues",
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
    if ([[WMMedicalHistoryGroup attributeNamesNotToSerialize] containsObject:propertyName] || [[WMMedicalHistoryGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMMedicalHistoryGroup relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end

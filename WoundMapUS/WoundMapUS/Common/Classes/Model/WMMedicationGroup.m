#import "WMMedicationGroup.h"
#import "WMMedication.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMMedicationGroup ()

// Private interface goes here.

@end


@implementation WMMedicationGroup

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMMedicationGroup *medicationGroup = [[WMMedicationGroup alloc] initWithEntity:[NSEntityDescription entityForName:@"WMMedicationGroup" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:medicationGroup toPersistentStore:store];
	}
    [medicationGroup setValue:[medicationGroup assignObjectId] forKey:[medicationGroup primaryKeyField]];
	return medicationGroup;
}

+ (WMMedicationGroup *)medicationGroupByRevising:(WMMedicationGroup *)medicationGroup
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (nil == medicationGroup) {
        return [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
    }
    // TODO else
    
    return nil;
}

+ (WMMedicationGroup *)activeMedicationGroup:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMMedicationGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"closedFlag == NO"]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (WMMedicationGroup *)mostRecentOrActiveMedicationGroup:(NSManagedObjectContext *)managedObjectContext
{
    WMMedicationGroup *medicationGroup = [self activeMedicationGroup:managedObjectContext];
    if (nil == medicationGroup) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"WMMedicationGroup" inManagedObjectContext:managedObjectContext]];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
        NSError *error = nil;
        NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
        if (nil != error) {
            [WMUtilities logError:error];
        }
        // else
        medicationGroup = [array lastObject];
    }
    return medicationGroup;
}

+ (NSDate *)mostRecentOrActiveMedicationGroupDateModified:(NSManagedObjectContext *)managedObjectContext
{
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMMedicationGroup"];
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
    NSDictionary *dates = [results firstObject];
    return dates[@"updatedAt"];
}

+ (NSInteger)closeMedicationGroupsCreatedBefore:(NSDate *)date
                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:@[store]];
    }
	[request setEntity:[NSEntityDescription entityForName:@"WMMedicationGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"closedFlag == NO AND dateCreated < %@", date]];
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

+ (BOOL)medicalGroupsHaveHistory:(NSManagedObjectContext *)managedObjectContext
{
    return [self medicalGroupsCount:managedObjectContext] > 1;
}

+ (NSInteger)medicalGroupsCount:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMMedicationGroup" inManagedObjectContext:managedObjectContext]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

+ (NSArray *)sortedMedicationGroups:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMMedicationGroup" inManagedObjectContext:managedObjectContext]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)isClosed
{
    return [self.closedFlag boolValue];
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
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMMedication" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"groups CONTAINS (%@)", self]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

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
    return  self.optionsArray;
}

@end

#import "WMWoundTreatmentGroup.h"
#import "WMPatient.h"
#import "WMWoundTreatmentValue.h"
#import "WMWound.h"
#import "WMWoundTreatment.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMWoundTreatmentGroup ()

// Private interface goes here.

@end


@implementation WMWoundTreatmentGroup

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundTreatmentGroup *woundTreatmentGroup = [[WMWoundTreatmentGroup alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentGroup" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundTreatmentGroup toPersistentStore:store];
	}
    [woundTreatmentGroup setValue:[woundTreatmentGroup assignObjectId] forKey:[woundTreatmentGroup primaryKeyField]];
	return woundTreatmentGroup;
}

+ (WMWoundTreatmentGroup *)woundTreatmentGroupForWound:(WMWound *)wound
{
    WMWoundTreatmentGroup *woundTreatmentGroup = [self instanceWithManagedObjectContext:[wound managedObjectContext] persistentStore:nil];
    woundTreatmentGroup.wound = wound;
    return woundTreatmentGroup;
}

+ (BOOL)woundTreatmentGroupsHaveHistory:(WMPatient *)patient
{
    return [self woundTreatmentGroupsInactiveOrClosedCount:patient] > 0;
}

+ (NSInteger)woundTreatmentGroupsCount:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

+ (NSInteger)woundTreatmentGroupsInactiveOrClosedCount:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND status.activeFlag == NO OR closedFlag == YES", patient]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

+ (NSDate *)mostRecentDateModified:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"dateModified"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"dateModified";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMWoundTreatmentGroup"];
    request.predicate = [NSPredicate predicateWithFormat:@"wound == %@", wound];
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
    return [results firstObject][@"dateModified"];
}

+ (WMWoundTreatmentGroup *)activeWoundTreatmentGroupForWound:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"wound == %@ AND status.activeFlag == YES AND closedFlag == NO", wound]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (NSInteger)closeWoundTreatmentGroupsCreatedBefore:(NSDate *)date
                                            patient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND dateCreated < %@", patient, date]];
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
    NSAssert([[woundTreatment managedObjectContext] isEqual:managedObjectContext], @"Invalid mocs");
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMWoundTreatmentValue" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND woundTreatment == %@", self, woundTreatment];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, [NSPredicate predicateWithFormat:@"value == %@", value], nil]];
    }
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
	// else
    WMWoundTreatmentValue *woundTreatmentValue = [array lastObject];
    if (create && nil == woundTreatmentValue) {
        woundTreatmentValue = [WMWoundTreatmentValue instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
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
    self.dateCreated = [NSDate date];
    self.dateModified = [NSDate date];
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

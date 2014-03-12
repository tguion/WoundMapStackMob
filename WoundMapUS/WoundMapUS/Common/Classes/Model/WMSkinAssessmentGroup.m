#import "WMSkinAssessmentGroup.h"
#import "WMPatient.h"
#import "WMSkinAssessment.h"
#import "WMSkinAssessmentValue.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMSkinAssessmentGroup ()

// Private interface goes here.

@end


@implementation WMSkinAssessmentGroup

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMSkinAssessmentGroup *skinAssessmentGroup = [[WMSkinAssessmentGroup alloc] initWithEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentGroup" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:skinAssessmentGroup toPersistentStore:store];
	}
    [skinAssessmentGroup setValue:[skinAssessmentGroup assignObjectId] forKey:[skinAssessmentGroup primaryKeyField]];
	return skinAssessmentGroup;
}

+ (WMSkinAssessmentGroup *)activeSkinAssessmentGroup:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND status.activeFlag == YES AND closedFlag == NO", patient]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (NSInteger)closeSkinAssessmentGroupsCreatedBefore:(NSDate *)date
                                            patient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentGroup" inManagedObjectContext:managedObjectContext]];
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

+ (WMSkinAssessmentGroup *)mostRecentOrActiveSkinAssessmentGroup:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
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
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequestAndWait:request
                                                 returnManagedObjectIDs:NO
                                                                options:options
                                                                  error:&error];
    if ([results count] == 0)
        return nil;
    // else
    return [results firstObject][@"updatedAt"];
}

+ (BOOL)skinAssessmentGroupsHaveHistory:(WMPatient *)patient
{
    return [self skinAssessmentGroupsCount:patient] > 1;
}

+ (NSInteger)skinAssessmentGroupsCount:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
    return [managedObjectContext countForFetchRequest:request error:NULL];
}

+ (NSArray *)sortedSkinAssessmentGroups:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentGroup" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
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
    return self.closedFlagValue;
}

- (WMSkinAssessmentValue *)skinAssessmentValueForSkinAssessment:(WMSkinAssessment *)skinAssessment
                                                         create:(BOOL)create
                                                          value:(id)value
{
    NSManagedObjectContext *managedObjectContext = [skinAssessment managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentValue" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND skinAssessment == %@", self, skinAssessment];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, [NSPredicate predicateWithFormat:@"value == %@", value], nil]];
    }
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    WMSkinAssessmentValue *skinAssessmentValue = [array lastObject];
    if (create && nil == skinAssessmentValue) {
        skinAssessmentValue = [WMSkinAssessmentValue instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
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

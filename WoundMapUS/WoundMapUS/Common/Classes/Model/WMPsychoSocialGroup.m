#import "WMPsychoSocialGroup.h"
#import "WMPatient.h"
#import "WMPsychoSocialItem.h"
#import "WMPsychoSocialValue.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMPsychoSocialGroup ()

// Private interface goes here.

@end


@implementation WMPsychoSocialGroup

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMPsychoSocialGroup *psychoSocialGroup = [[WMPsychoSocialGroup alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPsychoSocialGroup" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:psychoSocialGroup toPersistentStore:store];
	}
    [psychoSocialGroup setValue:[psychoSocialGroup assignObjectId] forKey:[psychoSocialGroup primaryKeyField]];
	return psychoSocialGroup;
}

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
    NSManagedObjectContext *managedObjectContext = [psychoSocialGroup managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@", psychoSocialGroup]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [NSSet setWithArray:array];
}

+ (WMPsychoSocialGroup *)activePsychoSocialGroup:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialGroup" inManagedObjectContext:managedObjectContext]];
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

+ (WMPsychoSocialGroup *)mostRecentOrActivePsychosocialGroup:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMPsychoSocialGroup *psychoSocialGroup = [self activePsychoSocialGroup:patient];
    if (nil == psychoSocialGroup) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialGroup" inManagedObjectContext:managedObjectContext]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]];
        [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
        NSError *error = nil;
        NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
        if (nil != error) {
            [WMUtilities logError:error];
        }
        // else
        psychoSocialGroup = [array lastObject];
    }
    return psychoSocialGroup;
}

+ (NSInteger)closePsychoSocialGroupsCreatedBefore:(NSDate *)date
                                          patient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialGroup" inManagedObjectContext:managedObjectContext]];
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

+ (NSArray *)sortedPsychoSocialGroups:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialGroup" inManagedObjectContext:managedObjectContext]];
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

+ (NSArray *)sortedPsychoSocialValuesForGroup:(WMPsychoSocialGroup *)group parentPsychoSocialItem:(WMPsychoSocialItem *)parentItem
{
    NSManagedObjectContext *managedObjectContext = [group managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND psychoSocialItem.parentItem == %@", group, parentItem]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"psychoSocialItem.sortRank" ascending:YES]]];
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequestAndWait:request
                                                 returnManagedObjectIDs:NO
                                                                options:options
                                                                  error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return results;
}

+ (NSArray *)sortedPsychoSocialValuesForGroup:(WMPsychoSocialGroup *)group psychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem
{
    NSManagedObjectContext *managedObjectContext = [group managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND psychoSocialItem == %@", group, psychoSocialItem]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"psychoSocialItem.sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

+ (BOOL)hasPsychoSocialValueForChildrenOfParentItem:(WMPsychoSocialGroup *)psychoSocialGroup
                             parentPsychoSocialItem:(WMPsychoSocialItem *)parentPsychoSocialItem
{
    NSManagedObjectContext *managedObjectContext = [psychoSocialGroup managedObjectContext];
    NSAssert([managedObjectContext isEqual:[parentPsychoSocialItem managedObjectContext]], @"Invalid mocs");
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialValue" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND (psychoSocialItem.parentItem == %@ OR psychoSocialItem.parentItem.parentItem == %@)", psychoSocialGroup, parentPsychoSocialItem, parentPsychoSocialItem];
    [request setPredicate:predicate];
    NSError *error = nil;
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSInteger count = [managedObjectContext countForFetchRequestAndWait:request options:(SMRequestOptions *)options error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return count;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (WMPsychoSocialValue *)psychoSocialValueForPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup
                                              psychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem
                                                        create:(BOOL)create
                                                         value:(NSString *)value
{
    NSManagedObjectContext *managedObjectContext = [psychoSocialGroup managedObjectContext];
    NSAssert([managedObjectContext isEqual:[psychoSocialItem managedObjectContext]], @"Invalid mocs");
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialValue" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %@ AND psychoSocialItem == %@", psychoSocialGroup, psychoSocialItem];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, [NSPredicate predicateWithFormat:@"value == %@", value], nil]];
    }
    [request setPredicate:predicate];
    NSError *error = nil;
    WMPsychoSocialValue *psychoSocialValue = [[managedObjectContext executeFetchRequestAndWait:request error:&error] lastObject];
    if (create && nil == psychoSocialValue) {
        psychoSocialValue = [WMPsychoSocialValue instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
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
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialValue" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"group == %@ AND psychoSocialItem.parentItem == %@", self, parentItem]];
    SMRequestOptions *options = [SMRequestOptions optionsWithFetchPolicy:SMFetchPolicyCacheOnly];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequestAndWait:request
                                                 returnManagedObjectIDs:NO
                                                                options:options
                                                                  error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [results lastObject];
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

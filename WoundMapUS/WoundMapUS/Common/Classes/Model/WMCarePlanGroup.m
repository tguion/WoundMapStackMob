#import "WMCarePlanGroup.h"
#import "WMPatient.h"
#import "WMCarePlanGroup.h"
#import "WMCarePlanCategory.h"
#import "WMCarePlanValue.h"
#import "WMUtilities.h"

@interface WMCarePlanGroup ()

// Private interface goes here.

@end


@implementation WMCarePlanGroup

- (NSArray *)sortedCarePlanValues
{
    return [[self.values allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"item.category.sortRank" ascending:YES],
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"item.sortRank" ascending:YES],
                                                                  nil]];
}

- (BOOL)isClosed
{
    return self.closedFlagValue;
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMCarePlanGroup *carePlanGroup = [[WMCarePlanGroup alloc] initWithEntity:[NSEntityDescription entityForName:@"WMCarePlanGroup" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:carePlanGroup toPersistentStore:store];
	}
	return carePlanGroup;
}

+ (WMCarePlanGroup *)activeCarePlanGroup:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    return [WMCarePlanGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND status.activeFlag == YES AND closedFlag == NO", patient]
                                             sortedBy:@"updatedAt"
                                            ascending:NO
                                            inContext:managedObjectContext];
}

+ (WMCarePlanGroup *)mostRecentOrActiveCarePlanGroup:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMCarePlanGroup *carePlanGroup = [self activeCarePlanGroup:patient];
    if (nil == carePlanGroup) {
        carePlanGroup = [WMCarePlanGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                                          sortedBy:@"updatedAt"
                                                         ascending:NO
                                                         inContext:managedObjectContext];
    }
    return carePlanGroup;
}

+ (NSDate *)mostRecentOrActiveCarePlanGroupDateModified:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSExpression *dateModifiedExpression = [NSExpression expressionForKeyPath:@"updatedAt"];
    NSExpressionDescription *dateModifiedExpressionDescription = [[NSExpressionDescription alloc] init];
    dateModifiedExpressionDescription.name = @"updatedAt";
    dateModifiedExpressionDescription.expression = [NSExpression expressionForFunction:@"max:" arguments:@[dateModifiedExpression]];
    dateModifiedExpressionDescription.expressionResultType = NSDateAttributeType;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"WMCarePlanGroup"];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = @[dateModifiedExpressionDescription];
    NSDictionary *date = (NSDictionary *)[WMCarePlanGroup MR_executeFetchRequestAndReturnFirstObject:request inContext:managedObjectContext];
    return date[@"updatedAt"];
}

+ (NSInteger)closeCarePlanGroupsCreatedBefore:(NSDate *)date
                                      patient:(WMPatient *)patient
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    NSArray *array = [WMCarePlanGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@ AND closedFlag == NO AND dateCreated < %@", patient, date]
                                                    inContext:managedObjectContext];
    [array makeObjectsPerformSelector:@selector(setClosedFlag:) withObject:@(1)];
    return [array count];
}

+ (NSSet *)carePlanValuesForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup
{
    return [NSSet setWithArray:[WMCarePlanGroup MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"group == %@", carePlanGroup] inContext:[carePlanGroup managedObjectContext]]];
}

+ (BOOL)carePlanGroupsHaveHistory:(WMPatient *)patient
{
    return [self carePlanGroupsCount:patient] > 1;
}

+ (NSInteger)carePlanGroupsCount:(WMPatient *)patient
{
    return [WMCarePlanGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient] inContext:[patient managedObjectContext]];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (NSArray *)sortedCarePlanGroups:(WMPatient *)patient
{
    return [WMCarePlanGroup MR_findAllSortedBy:@"createdAt"
                                     ascending:NO
                                 withPredicate:[NSPredicate predicateWithFormat:@"patient == %@", patient]
                                     inContext:[patient managedObjectContext]];
}

- (WMCarePlanValue *)carePlanValueForPatient:(WMPatient *)patient
                            carePlanCategory:(WMCarePlanCategory *)carePlanCategory
                                      create:(BOOL)create
                                       value:(NSString *)value
{
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    if (nil != carePlanCategory) {
        NSParameterAssert(managedObjectContext == [carePlanCategory managedObjectContext]);
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group.patient == %@ AND category == %@", patient, carePlanCategory];
    if (nil != value) {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, [NSPredicate predicateWithFormat:@"value == %@", value], nil]];
    }
    WMCarePlanValue *carePlanValue = [WMCarePlanValue MR_findFirstWithPredicate:predicate inContext:managedObjectContext];
    if (create && nil == carePlanValue) {
        carePlanValue = [WMCarePlanValue instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        carePlanValue.category = carePlanCategory;
        carePlanValue.value = value;
        carePlanValue.title = carePlanCategory.title;
        [self addValuesObject:carePlanValue];
    }
    return carePlanValue;
}

- (WMCarePlanCategory *)carePlanCategoryForParentCategory:(WMCarePlanCategory *)parentCategory
{
    NSArray *categories = [parentCategory.subcategories allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category IN (%@)", categories];
    NSArray *values = [[self.values allObjects] filteredArrayUsingPredicate:predicate];
    return [[values lastObject] valueForKey:@"category"];
}

- (BOOL)hasValueForCategoryOrDescendants:(WMCarePlanCategory *)carePlanCategory
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:32];
    [carePlanCategory aggregateSubcategories:set];
    NSMutableSet *categories = [[self.values valueForKeyPath:@"category"] mutableCopy];
    return [set intersectsSet:categories];
}

- (void)removeCarePlanValuesForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", carePlanCategory];
    NSArray *values = [[self.values allObjects] filteredArrayUsingPredicate:predicate];
    for (WMCarePlanValue *value in values) {
        [self removeValuesObject:value];
        [managedObjectContext deleteObject:value];
    }
}

- (void)incrementContinueCount
{
    self.continueCount = [NSNumber numberWithInt:([self.continueCount intValue] + 1)];
}

- (NSInteger)valuesCountForCarePlanCategory:(WMCarePlanCategory *)carePlanCategory
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:32];
    [carePlanCategory aggregateSubcategories:set];
    // do not rely on the cache self.values toMany relationship - fetch fresh from store
    NSMutableSet *categories = [[[WMCarePlanGroup carePlanValuesForCarePlanGroup:self] valueForKeyPath:@"category"] mutableCopy];
    [set intersectSet:categories];
    return [set count];
}

// refetch all data from datastore
- (void)refreshData
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSSet *values = [WMCarePlanGroup carePlanValuesForCarePlanGroup:self];
    for (WMCarePlanValue *value in values) {
        [managedObjectContext refreshObject:value mergeChanges:value.hasChanges];
    }
    NSSet *carePlanCategories = [WMCarePlanCategory carePlanCategories:managedObjectContext];
    for (WMCarePlanCategory *category in carePlanCategories) {
        [managedObjectContext refreshObject:category mergeChanges:category.hasChanges];
    }
}

#pragma mark - AssessmentGroup

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

- (GroupValueTypeCode)groupValueTypeCode
{
    return GroupValueTypeCodeSelect;
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

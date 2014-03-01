#import "WMCarePlanCategory.h"
#import "WMCarePlanItem.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

typedef enum {
    WMCarePlanCategoryFlagsInputValueInline             = 0,
    WMCarePlanCategoryFlagsSkipSelectionIcon            = 1,
    WMCarePlanCategoryFlagsCombineKeyAndValue           = 2,
    WMCarePlanCategoryFlagsAllowMultipleChildSelection  = 3,
} WMCarePlanCategoryFlags;

@interface WMCarePlanCategory ()

// Private interface goes here.

@end


@implementation WMCarePlanCategory

- (BOOL)combineKeyAndValue
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsCombineKeyAndValue];
}

- (void)setCombineKeyAndValue:(BOOL)combineKeyAndValue
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsCombineKeyAndValue to:combineKeyAndValue]];
}

- (BOOL)inputValueInline
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsInputValueInline];
}

- (void)setInputValueInline:(BOOL)inputValueInline
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsInputValueInline to:inputValueInline]];
}

- (BOOL)allowMultipleChildSelection
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsAllowMultipleChildSelection];
}

- (void)setAllowMultipleChildSelection:(BOOL)allowMultipleChildrenSelection
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsAllowMultipleChildSelection to:allowMultipleChildrenSelection]];
}

- (BOOL)skipSelectionIcon
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsSkipSelectionIcon];
}

- (void)setSkipSelectionIcon:(BOOL)skipSelectionIcon
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsSkipSelectionIcon to:skipSelectionIcon]];
}

- (BOOL)hasSubcategories
{
    return [self.subcategories count] > 0;
}

// add self and all subcategories with their subcategories and items
- (void)aggregateSubcategories:(NSMutableSet *)set
{
    [set addObject:self];
    for (WMCarePlanCategory *subcategory in self.subcategories) {
        [subcategory aggregateSubcategories:set];
    }
}

- (NSArray *)sortedChildernCarePlanCategories
{
    return [[self.subcategories allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
}

- (NSString *)combineKeyAndValue:(NSString *)value
{
    return [self.title stringByReplacingOccurrencesOfString:@"_" withString:value];
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMCarePlanCategory *carePlanCategory = [[WMCarePlanCategory alloc] initWithEntity:[NSEntityDescription entityForName:@"WMCarePlanCategory" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:carePlanCategory toPersistentStore:store];
	}
    [carePlanCategory setValue:[carePlanCategory assignObjectId] forKey:[carePlanCategory primaryKeyField]];
	return carePlanCategory;
}

+ (NSArray *)sortedRootCarePlanCategories:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMCarePlanCategory" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parent = nil"]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

+ (WMCarePlanCategory *)carePlanCategoryForTitle:(NSString *)title
                                          parent:(WMCarePlanCategory *)parent
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:@[store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMCarePlanCategory" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND parent == %@", title, parent]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMCarePlanCategory *carePlanCategory = [array lastObject];
    if (create && nil == carePlanCategory) {
        carePlanCategory = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:nil];
        carePlanCategory.title = title;
        carePlanCategory.parent = parent;
    }
    return carePlanCategory;
}

+ (WMCarePlanCategory *)updateCarePlanCategoryFromDictionary:(NSDictionary *)dictionary
                                                      parent:(WMCarePlanCategory *)parent
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                             persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMCarePlanCategory *carePlanCategory = [self carePlanCategoryForTitle:title
                                                                   parent:parent
                                                                   create:YES
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store];
    carePlanCategory.definition = [dictionary objectForKey:@"definition"];
    carePlanCategory.loincCode = [dictionary objectForKey:@"LOINC Code"];
    carePlanCategory.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    carePlanCategory.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    carePlanCategory.sortRank = [dictionary objectForKey:@"sortRank"];
    carePlanCategory.placeHolder = [dictionary objectForKey:@"placeHolder"];
    carePlanCategory.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
    carePlanCategory.inputValueInline = [[dictionary objectForKey:@"inlineFlag"] boolValue];
    carePlanCategory.keyboardType = [dictionary objectForKey:@"keyboardType"];
    carePlanCategory.skipSelectionIcon = [[dictionary objectForKey:@"skipSelectionIcon"] boolValue];
    carePlanCategory.combineKeyAndValue = [[dictionary objectForKey:@"combineKeyAndValue"] boolValue];
    carePlanCategory.allowMultipleChildSelection = [[dictionary objectForKey:@"allowMultipleChildSelection"] boolValue];
    id woundTypeCodes = [dictionary objectForKey:@"woundTypeCodes"];
    if ([woundTypeCodes isKindOfClass:[NSString class]]) {
        NSArray *typeCodes = [woundTypeCodes componentsSeparatedByString:@","];
        NSMutableSet *set = [NSMutableSet set];
        for (id typeCode in typeCodes) {
            NSArray *woundTypes = [WMWoundType woundTypesForWoundTypeCode:[typeCode integerValue]
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store];
            [set addObjectsFromArray:woundTypes];
        }
        [carePlanCategory setWoundTypes:set];
    }
    // now subcategories
    id subcategories = [dictionary objectForKey:@"subcategories"];
    for (NSDictionary *d in subcategories) {
        [self updateCarePlanCategoryFromDictionary:d
                                            parent:carePlanCategory
                              managedObjectContext:managedObjectContext
                                   persistentStore:store];
    }
    // now options
    id options = [dictionary objectForKey:@"options"];
    for (NSDictionary *d in options) {
        // check if we are at the leaf of the tree
        [self updateCarePlanCategoryFromDictionary:d
                                            parent:carePlanCategory
                              managedObjectContext:managedObjectContext
                                   persistentStore:store];
    }
    return carePlanCategory;
}

+ (NSSet *)carePlanCategories:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMCarePlanCategory" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [NSSet setWithArray:array];
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"CarePlan" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"CarePlan.plist file not found");
		return;
	}
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an array, class was %@", NSStringFromClass([propertyList class]));
        for (NSDictionary *dictionary in propertyList) {
            [self updateCarePlanCategoryFromDictionary:dictionary parent:nil managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

+ (NSPredicate *)predicateForParent:(WMCarePlanCategory *)parent woundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return [NSPredicate predicateWithFormat:@"parent == %@", parent];
    }
    // else
    return [NSPredicate predicateWithFormat:@"parent == %@ AND (woundTypes.@count == 0 OR ANY woundTypes == %@)", parent, woundType];
}

#pragma mark - AssessmentGroup

- (GroupValueTypeCode)groupValueTypeCode
{
    return [self.valueTypeCode intValue];
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
    return [self.options componentsSeparatedByString:@","];
}

- (NSArray *)secondaryOptionsArray
{
    return self.optionsArray;
}

- (NSSet *)interventionEvents
{
    return [NSSet set];
}

- (void)setInterventionEvents:(NSSet *)interventionEvents
{
}

@end

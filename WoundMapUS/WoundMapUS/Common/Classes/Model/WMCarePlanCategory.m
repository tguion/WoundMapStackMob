#import "WMCarePlanCategory.h"
#import "WMWoundType.h"
#import "WMUtilities.h"

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

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)combineKeyAndValue
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsCombineKeyAndValue];
}

- (void)setCombineKeyAndValue:(BOOL)combineKeyAndValue
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsCombineKeyAndValue to:combineKeyAndValue]);
}

- (BOOL)inputValueInline
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsInputValueInline];
}

- (void)setInputValueInline:(BOOL)inputValueInline
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsInputValueInline to:inputValueInline]);
}

- (BOOL)allowMultipleChildSelection
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsAllowMultipleChildSelection];
}

- (void)setAllowMultipleChildSelection:(BOOL)allowMultipleChildrenSelection
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsAllowMultipleChildSelection to:allowMultipleChildrenSelection]);
}

- (BOOL)skipSelectionIcon
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsSkipSelectionIcon];
}

- (void)setSkipSelectionIcon:(BOOL)skipSelectionIcon
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMCarePlanCategoryFlagsSkipSelectionIcon to:skipSelectionIcon]);
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

+ (NSArray *)sortedRootCarePlanCategories:(NSManagedObjectContext *)managedObjectContext
{
    return [WMCarePlanCategory MR_findAllSortedBy:@"sortRank"
                                        ascending:YES
                                    withPredicate:[NSPredicate predicateWithFormat:@"parent = nil"]
                                        inContext:managedObjectContext];
}

+ (WMCarePlanCategory *)carePlanCategoryForTitle:(NSString *)title
                                          parent:(WMCarePlanCategory *)parent
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (nil != parent) {
        NSParameterAssert(managedObjectContext == [parent managedObjectContext]);
    }
    WMCarePlanCategory *carePlanCategory = [WMCarePlanCategory MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND parent == %@", title, parent] inContext:managedObjectContext];
    if (create && nil == carePlanCategory) {
        carePlanCategory = [WMCarePlanCategory MR_createInContext:managedObjectContext];
        carePlanCategory.title = title;
        carePlanCategory.parent = parent;
    }
    return carePlanCategory;
}

+ (WMCarePlanCategory *)updateCarePlanCategoryFromDictionary:(NSDictionary *)dictionary
                                                      parent:(WMCarePlanCategory *)parent
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                   objectIDs:(NSMutableArray *)objectIDs
{
    id title = [dictionary objectForKey:@"title"];
    WMCarePlanCategory *carePlanCategory = [self carePlanCategoryForTitle:title
                                                                   parent:parent
                                                                   create:YES
                                                     managedObjectContext:managedObjectContext];
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
                                                     managedObjectContext:managedObjectContext];
            [set addObjectsFromArray:woundTypes];
        }
        [carePlanCategory setWoundTypes:set];
    }
    [managedObjectContext MR_saveOnlySelfAndWait];
    [objectIDs addObject:[carePlanCategory objectID]];
    // now subcategories
    id subcategories = [dictionary objectForKey:@"subcategories"];
    for (NSDictionary *d in subcategories) {
        [self updateCarePlanCategoryFromDictionary:d
                                            parent:carePlanCategory
                              managedObjectContext:managedObjectContext
                                         objectIDs:objectIDs];
    }
    // now options
    id options = [dictionary objectForKey:@"options"];
    for (NSDictionary *d in options) {
        // check if we are at the leaf of the tree
        [self updateCarePlanCategoryFromDictionary:d
                                            parent:carePlanCategory
                              managedObjectContext:managedObjectContext
                                         objectIDs:objectIDs];
    }
    return carePlanCategory;
}

+ (NSSet *)carePlanCategories:(NSManagedObjectContext *)managedObjectContext
{
    return [NSSet setWithArray:[WMCarePlanCategory MR_findAllInContext:managedObjectContext]];
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
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
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            WMCarePlanCategory *carePlanCategory = [self updateCarePlanCategoryFromDictionary:dictionary
                                                                                       parent:nil
                                                                         managedObjectContext:managedObjectContext
                                                                                    objectIDs:objectIDs];
            [managedObjectContext MR_saveOnlySelfAndWait];
            NSAssert(![[carePlanCategory objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[carePlanCategory objectID]];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMCarePlanCategory entityName], nil);
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

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"keyboardTypeValue",
                                                            @"snomedCIDValue",
                                                            @"sortRankValue",
                                                            @"valueTypeCodeValue",
                                                            @"groupValueTypeCode",
                                                            @"title",
                                                            @"value",
                                                            @"placeHolder",
                                                            @"unit",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"objectID",
                                                            @"combineKeyAndValue",
                                                            @"inputValueInline",
                                                            @"allowMultipleChildSelection",
                                                            @"skipSelectionIcon",
                                                            @"hasSubcategories",
                                                            @"sortedChildernCarePlanCategories"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMCarePlanCategoryRelationships.subcategories]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMCarePlanCategory attributeNamesNotToSerialize] containsObject:propertyName] || [[WMCarePlanCategory relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMCarePlanCategory relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
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

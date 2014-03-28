#import "WMPsychoSocialItem.h"
#import "WMWoundType.h"
#import "WMUtilities.h"

typedef enum {
    WCPsychoSocialItemFlagsAllowMultipleChildSelection  = 0,
} WCPsychoSocialItemFlags;

@interface WMPsychoSocialItem ()

// Private interface goes here.

@end


@implementation WMPsychoSocialItem

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (NSInteger)updatedScore
{
    return 0;//TODO finish
}

- (BOOL)hasSubItems
{
    return [self.subitems count] > 0;
}

- (BOOL)allowMultipleChildSelection
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WCPsychoSocialItemFlagsAllowMultipleChildSelection];
}

- (void)setAllowMultipleChildSelection:(BOOL)allowMultipleChildrenSelection
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WCPsychoSocialItemFlagsAllowMultipleChildSelection to:allowMultipleChildrenSelection]);
}

// add self, all items, and all subcategories with their subcategories and items
- (void)aggregatePsychoSocialItems:(NSMutableSet *)set
{
    [set addObject:self];
    for (WMPsychoSocialItem *subitem in self.subitems) {
        [subitem aggregatePsychoSocialItems:set];
    }
    [set unionSet:self.subitems];
}

+ (NSPredicate *)predicateForParent:(WMPsychoSocialItem *)parentItem woundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return [NSPredicate predicateWithFormat:@"parentItem == %@", parentItem];
    }
    // else
    return [NSPredicate predicateWithFormat:@"parentItem == %@ AND (woundTypes.@count == 0 OR ANY woundTypes == %@)", parentItem, woundType];
}

+ (NSArray *)sortedPsychoSocialItemsForParentItem:(WMPsychoSocialItem *)parentItem
                             managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (parentItem) {
        NSParameterAssert([parentItem managedObjectContext] == managedObjectContext);
    }
    return [WMPsychoSocialItem MR_findAllSortedBy:@"sortRank" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"parentItem == %@", parentItem] inContext:managedObjectContext];
}

+ (WMPsychoSocialItem *)psychoSocialItemForTitle:(NSString *)title
                                      parentItem:(WMPsychoSocialItem *)parentItem
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@ AND parentItem == %@", title, parentItem];
    NSAssert([WMPsychoSocialItem MR_countOfEntitiesWithPredicate:predicate inContext:managedObjectContext] < 2, @"Bad data");
    WMPsychoSocialItem *psychoSocialItem = [WMPsychoSocialItem MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND parentItem == %@", title, parentItem] inContext:managedObjectContext];
    if (create && nil == psychoSocialItem) {
        psychoSocialItem = [WMPsychoSocialItem MR_createInContext:managedObjectContext];
        psychoSocialItem.title = title;
        psychoSocialItem.parentItem = parentItem;
    }
    return psychoSocialItem;
}

#pragma mark - Seed database

+ (WMPsychoSocialItem *)updatePsychoSocialItemFromDictionary:(NSDictionary *)dictionary
                                                  parentItem:(WMPsychoSocialItem *)parentItem
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                   objectIDs:(NSMutableArray *)objectIDs
{
    id title = [dictionary objectForKey:@"title"];
    WMPsychoSocialItem *psychoSocialItem = [self psychoSocialItemForTitle:title
                                                               parentItem:(WMPsychoSocialItem *)parentItem
                                                                   create:YES
                                                     managedObjectContext:managedObjectContext];
    psychoSocialItem.definition = [dictionary objectForKey:@"definition"];
    psychoSocialItem.loincCode = [dictionary objectForKey:@"LOINC Code"];
    psychoSocialItem.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    psychoSocialItem.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    psychoSocialItem.sortRank = [dictionary objectForKey:@"sortRank"];
    psychoSocialItem.subtitle = [dictionary objectForKey:@"subtitle"];
    id sectionTitle = [dictionary objectForKey:@"sectionTitle"];
    if (nil == sectionTitle) {
        sectionTitle = @"Answers";
    }
    psychoSocialItem.sectionTitle = sectionTitle;
    psychoSocialItem.options = [dictionary objectForKey:@"options"];
    psychoSocialItem.valueTypeCode = [dictionary objectForKey:@"valueTypeCode"];
    psychoSocialItem.subitemPrompt = [dictionary objectForKey:@"subitemPrompt"];
    psychoSocialItem.prefixTitle = [dictionary objectForKey:@"prefixTitle"];
    id score = [dictionary objectForKey:@"score"];
    if (nil != score) {
        psychoSocialItem.score = score;
    }
    id woundTypeCodes = [dictionary objectForKey:@"woundTypeCodes"];
    if ([woundTypeCodes isKindOfClass:[NSString class]]) {
        NSArray *typeCodes = [woundTypeCodes componentsSeparatedByString:@","];
        NSMutableSet *set = [NSMutableSet set];
        for (id typeCode in typeCodes) {
            NSArray *woundTypes = [WMWoundType woundTypesForWoundTypeCode:[typeCode integerValue]
                                                     managedObjectContext:managedObjectContext];
            [set addObjectsFromArray:woundTypes];
        }
        [psychoSocialItem setWoundTypes:set];
    }
    [managedObjectContext MR_saveOnlySelfAndWait];
    NSAssert(![[psychoSocialItem objectID] isTemporaryID], @"Expect a permanent objectID");
    [objectIDs addObject:[psychoSocialItem objectID]];
    // subitems
    id subitems = [dictionary objectForKey:@"subitems"];
    for (NSDictionary *d in subitems) {
        [self updatePsychoSocialItemFromDictionary:d
                                        parentItem:psychoSocialItem
                              managedObjectContext:managedObjectContext
                                         objectIDs:objectIDs];
    }
    return psychoSocialItem;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"PsychoSocial" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"PsychoSocial.plist file not found");
		return;
	}
    // else
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
            [self updatePsychoSocialItemFromDictionary:dictionary
                                            parentItem:nil
                                  managedObjectContext:managedObjectContext
                                             objectIDs:objectIDs];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMPsychoSocialItem entityName]);
        }
    }
}

#pragma mark - FatFractal

+ (NSArray *)attributeNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[@"flagsValue",
                                        @"scoreValue",
                                        @"snomedCIDValue",
                                        @"sortRankValue",
                                        @"valueTypeCodeValue",
                                        @"groupValueTypeCode",
                                        @"unit",
                                        @"value",
                                        @"optionsArray",
                                        @"secondaryOptionsArray",
                                        @"interventionEvents",
                                        @"hasSubItems",
                                        @"allowMultipleChildSelection",
                                        @"updatedScore"];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSArray *)relationshipNamesNotToSerialize
{
    static NSArray *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = @[WMPsychoSocialItemRelationships.subitems,
                                        WMPsychoSocialItemRelationships.values];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMPsychoSocialItem attributeNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMPsychoSocialItem relationshipNamesNotToSerialize] containsObject:propertyName]) {
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

- (NSString *)placeHolder
{
    return nil;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    
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

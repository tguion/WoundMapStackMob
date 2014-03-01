#import "WMPsychoSocialItem.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

typedef enum {
    WCPsychoSocialItemFlagsAllowMultipleChildSelection  = 0,
} WCPsychoSocialItemFlags;

@interface WMPsychoSocialItem ()

// Private interface goes here.

@end


@implementation WMPsychoSocialItem

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMPsychoSocialItem *psychoSocialItem = [[WMPsychoSocialItem alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPsychoSocialItem" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:psychoSocialItem toPersistentStore:store];
	}
    [psychoSocialItem setValue:[psychoSocialItem assignObjectId] forKey:[psychoSocialItem primaryKeyField]];
	return psychoSocialItem;
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
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WCPsychoSocialItemFlagsAllowMultipleChildSelection to:allowMultipleChildrenSelection]];
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
                                  persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialItem" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parentItem == %@", parentItem]];
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

+ (WMPsychoSocialItem *)psychoSocialItemForTitle:(NSString *)title
                                      parentItem:(WMPsychoSocialItem *)parentItem
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMPsychoSocialItem" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND parentItem == %@", title, parentItem]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMPsychoSocialItem *psychoSocialItem = [array lastObject];
    if (create && nil == psychoSocialItem) {
        psychoSocialItem = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        psychoSocialItem.title = title;
        psychoSocialItem.parentItem = parentItem;
    }
    return psychoSocialItem;
}

#pragma mark - Seed database

+ (WMPsychoSocialItem *)updatePsychoSocialItemFromDictionary:(NSDictionary *)dictionary
                                                  parentItem:(WMPsychoSocialItem *)parentItem
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                             persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMPsychoSocialItem *psychoSocialItem = [self psychoSocialItemForTitle:title
                                                               parentItem:(WMPsychoSocialItem *)parentItem
                                                                   create:YES
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store];
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
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store];
            [set addObjectsFromArray:woundTypes];
        }
        [psychoSocialItem setWoundTypes:set];
    }
    // subitems
    id subitems = [dictionary objectForKey:@"subitems"];
    for (NSDictionary *d in subitems) {
        [self updatePsychoSocialItemFromDictionary:d
                                        parentItem:psychoSocialItem
                              managedObjectContext:managedObjectContext
                                   persistentStore:store];
    }
    return psychoSocialItem;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
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
        [managedObjectContext performBlockAndWait:^{
            for (NSDictionary *dictionary in propertyList) {
                [self updatePsychoSocialItemFromDictionary:dictionary
                                                parentItem:nil
                                      managedObjectContext:managedObjectContext
                                           persistentStore:store];
            }
        }];
    }
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

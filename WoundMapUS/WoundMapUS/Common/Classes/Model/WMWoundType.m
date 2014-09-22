#import "WMWoundType.h"
#import "WMUtilities.h"

NSString * const kOtherWoundTypeTitle = @"Other";

@interface WMWoundType ()

// Private interface goes here.

@end


@implementation WMWoundType

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)isOther
{
    return [kOtherWoundTypeTitle isEqualToString:self.title];
}

- (BOOL)hasChildrenWoundTypes
{
    return [self.children count] > 0;
}

- (BOOL)childrenHaveSectionTitles
{
    if (!self.hasChildrenWoundTypes) {
        return NO;
    }
    // else
    for (WMWoundType *woundType in self.children) {
        if ([woundType.sectionTitle length] > 0) {
            return YES;
        }
    }
    // else
    return NO;
}

- (NSString *)titleForDisplay
{
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:4];
    WMWoundType *woundType = self;
    while (nil != woundType) {
        [titles insertObject:woundType.title atIndex:0];
        woundType = woundType.parent;
    }
    return [titles componentsJoinedByString:@","];
}

+ (NSInteger)woundTypeCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundType MR_countOfEntitiesWithContext:managedObjectContext];
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WoundType" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"WoundType.plist file not found");
		return;
	}
    // else see if seeded
    NSInteger count = [self woundTypeCount:managedObjectContext];
    if (count > 0 && count != NSNotFound) {
        return;
    }
    // else
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        NSError *error = nil;
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an NSArray, class was %@", NSStringFromClass([propertyList class]));
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            [self updateWoundTypeFromDictionary:dictionary managedObjectContext:managedObjectContext objectIDs:objectIDs];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMWoundType entityName], nil);
        }
    }
}

+ (WMWoundType *)updateWoundTypeFromDictionary:(NSDictionary *)dictionary
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                     objectIDs:(NSMutableArray *)objectIDs
{
    id title = [dictionary objectForKey:@"title"];
    WMWoundType *woundType = [WMWoundType woundTypeForTitle:title
                                                     create:YES
                                       managedObjectContext:managedObjectContext];
    woundType.definition = [dictionary objectForKey:@"definition"];
    woundType.label = [dictionary objectForKey:@"label"];
    woundType.options = [dictionary objectForKey:@"options"];
    woundType.placeHolder = [dictionary objectForKey:@"placeHolder"];
    woundType.valueTypeCode = [dictionary objectForKey:@"valueTypeCode"];
    woundType.woundTypeCode = [dictionary objectForKey:@"woundTypeCode"];
    woundType.sectionTitle = [dictionary objectForKey:@"sectionTitle"];
    woundType.sortRank = [dictionary objectForKey:@"sortRank"];
    woundType.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    woundType.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    woundType.loincCode = [dictionary objectForKey:@"LOINC Code"];
    [managedObjectContext MR_saveOnlySelfAndWait];
    NSAssert(![[woundType objectID] isTemporaryID], @"Expect a permanent objectID");
    [objectIDs addObject:[woundType objectID]];
    id children = [dictionary objectForKey:@"children"];
    if ([children isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in children) {
            WMWoundType *childWoundType = [self updateWoundTypeFromDictionary:d managedObjectContext:managedObjectContext objectIDs:objectIDs];
            childWoundType.parent = woundType;
        }
    }
    return woundType;
}

+ (WMWoundType *)woundTypeForTitle:(NSString *)title
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMWoundType *woundType = [WMWoundType MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == woundType) {
        woundType = [WMWoundType MR_createInContext:managedObjectContext];
        woundType.title = title;
    }
    return woundType;
}

+ (NSArray *)woundTypesForWoundTypeCode:(NSInteger)woundTypeCodeValue
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundType MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"woundTypeCode == %d", woundTypeCodeValue] inContext:managedObjectContext];
}

+ (WMWoundType *)otherWoundType:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundType MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", kOtherWoundTypeTitle] inContext:managedObjectContext];
}

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return nil;
}

- (BOOL)requireUpdatesFromCloud
{
    return NO;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"childrenHaveSectionTitles",
                                                            @"flagsValue",
                                                            @"hasChildrenWoundTypes",
                                                            @"isOther",
                                                            @"optionsArray",
                                                            @"snomedCIDValue",
                                                            @"sortRankValue",
                                                            @"titleForDisplay",
                                                            @"valueTypeCodeValue",
                                                            @"woundTypeCodeValue",
                                                            @"groupValueTypeCode",
                                                            @"unit",
                                                            @"value",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"interventionEvents",
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMWoundTypeRelationships.carePlanCategories,
                                                            WMWoundTypeRelationships.children,
                                                            WMWoundTypeRelationships.deviceCategories,
                                                            WMWoundTypeRelationships.iapProducts,
                                                            WMWoundTypeRelationships.medicationCategories,
                                                            WMWoundTypeRelationships.psychosocialItems,
                                                            WMWoundTypeRelationships.skinAssessmentCategories,
                                                            WMWoundTypeRelationships.woundMeasurements,
                                                            WMWoundTypeRelationships.wounds,
                                                            WMWoundTypeRelationships.woundTreatments]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMWoundType attributeNamesNotToSerialize] containsObject:propertyName] || [[WMWoundType relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundType relationshipNamesNotToSerialize] containsObject:propertyName]) {
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
    return [NSArray array];
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

#import "WMWoundTreatment.h"
#import "WMWoundTreatmentValue.h"
#import "WMWoundType.h"
#import "WMUtilities.h"

typedef enum {
    WoundTreatmentFlagsInputValueInline             = 0,
    WoundTreatmentFlagsAllowMultipleChildSelection  = 1,
    WoundTreatmentFlagsOtherFlag                    = 2,
    WoundTreatmentFlagsCombineKeyAndValue           = 3,
    WoundTreatmentFlagsSkipSelectionIcon            = 4,
    WoundTreatmentFlagsNormalizeChildInputs         = 5,
} WoundTreatmentFlags;


@interface WMWoundTreatment ()

// Private interface goes here.

@end


@implementation WMWoundTreatment

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)combineKeyAndValue
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsCombineKeyAndValue];
}

- (void)setCombineKeyAndValue:(BOOL)combineKeyAndValue
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsCombineKeyAndValue to:combineKeyAndValue]);
}

- (BOOL)allowMultipleChildSelection
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsAllowMultipleChildSelection];
}

- (void)setAllowMultipleChildSelection:(BOOL)allowMultipleChildrenSelection
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsAllowMultipleChildSelection to:allowMultipleChildrenSelection]);
}

- (NSArray *)sortedChildrenWoundTreatments
{
    return [[self.childrenTreatments allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
}

- (BOOL)hasChildrenWoundTreatments
{
    return [self.childrenTreatments count] > 0;
}

- (BOOL)childrenHaveSectionTitles
{
    if (!self.hasChildrenWoundTreatments) {
        return NO;
    }
    // else
    for (WMWoundTreatment *woundTreatment in self.childrenTreatments) {
        if ([woundTreatment.sectionTitle length] > 0) {
            return YES;
        }
    }
    // else
    return NO;
}

- (BOOL)skipSelectionIcon
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsSkipSelectionIcon];
}

- (void)setSkipSelectionIcon:(BOOL)skipSelectionIcon
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsSkipSelectionIcon to:skipSelectionIcon]);
}

- (BOOL)normalizeMeasurements
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsNormalizeChildInputs];
}

- (void)setNormalizeMeasurements:(BOOL)normalizeMeasurements
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsNormalizeChildInputs to:normalizeMeasurements]);
}

- (NSString *)combineKeyAndValue:(NSString *)value
{
    return [self.title stringByReplacingOccurrencesOfString:@"_" withString:value];
}

- (void)aggregateWoundTreatments:(NSMutableSet *)set
{
    [set addObject:self];
    for (WMWoundTreatment *woundTreatment in self.childrenTreatments) {
        [woundTreatment aggregateWoundTreatments:set];
    }
    [set unionSet:self.childrenTreatments];
}

+ (WMWoundTreatment *)woundTreatmentForTitle:(NSString *)title
                        parentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (parentWoundTreatment) {
        NSParameterAssert([parentWoundTreatment managedObjectContext] == managedObjectContext);
    }
    WMWoundTreatment *woundTreatment = [WMWoundTreatment MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND parentTreatment == %@", title, parentWoundTreatment] inContext:managedObjectContext];
    if (create && nil == woundTreatment) {
        woundTreatment = [WMWoundTreatment MR_createInContext:managedObjectContext];
        woundTreatment.title = title;
        woundTreatment.parentTreatment = parentWoundTreatment;
    }
    return woundTreatment;
}

+ (NSArray *)sortedRootWoundTreatments:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundTreatment MR_findAllSortedBy:WMWoundTreatmentAttributes.sortRank ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"parentTreatment = nil"] inContext:managedObjectContext];
}

+ (WMWoundTreatment *)updateWoundTreatmentFromDictionary:(NSDictionary *)dictionary
                                    parentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment
                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMWoundTreatment *treatment = [self woundTreatmentForTitle:title
                                          parentWoundTreatment:parentWoundTreatment
                                                        create:YES
                                          managedObjectContext:managedObjectContext];
    treatment.sortRank = [dictionary objectForKey:@"sortRank"];
    treatment.placeHolder = [dictionary objectForKey:@"placeHolder"];
    treatment.sectionTitle = [dictionary objectForKey:@"sectionTitle"];
    treatment.unit = [dictionary objectForKey:@"unit"];
    treatment.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
    treatment.keyboardType = [dictionary objectForKey:@"keyboardType"];
    treatment.combineKeyAndValue = [[dictionary objectForKey:@"combineKeyAndValue"] boolValue];
    treatment.allowMultipleChildSelection = [[dictionary objectForKey:@"allowMultipleChildSelection"] boolValue];
    treatment.skipSelectionIcon = [[dictionary objectForKey:@"skipSelectionIcon"] boolValue];
    treatment.normalizeMeasurements = [[dictionary objectForKey:@"normalizeMeasurements"] boolValue];
    treatment.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    treatment.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    treatment.loincCode = [dictionary objectForKey:@"LOINC Code"];
    // restricting to wound type
    id woundTypeCodes = [dictionary objectForKey:@"woundTypeCodes"];
    if ([woundTypeCodes isKindOfClass:[NSString class]]) {
        NSArray *typeCodes = [woundTypeCodes componentsSeparatedByString:@","];
        NSMutableSet *set = [NSMutableSet set];
        for (id typeCode in typeCodes) {
            NSArray *woundTypes = [WMWoundType woundTypesForWoundTypeCode:[typeCode integerValue]
                                                     managedObjectContext:managedObjectContext];
            [set addObjectsFromArray:woundTypes];
        }
        [treatment setWoundTypes:set];
    }
    id children = [dictionary valueForKey:@"children"];
    if ([children isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in children) {
            [self updateWoundTreatmentFromDictionary:d
                                parentWoundTreatment:treatment
                                managedObjectContext:managedObjectContext];
        }
    }
    return treatment;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    // read the plist
    NSString *filename = @"WoundTreatment";
    if (kSeedFileSuffix) {
        filename = [filename stringByAppendingString:kSeedFileSuffix];
    }
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"WoundTreatment.plist file not found");
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
        for (NSDictionary *dictionary in propertyList) {
            [self updateWoundTreatmentFromDictionary:dictionary
                                parentWoundTreatment:nil
                                managedObjectContext:managedObjectContext];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (!completionHandler) {
            return;
        }
        // else collect objectIDs in order consistent with ff
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentTreatment = nil"];
        NSArray *objects = [WMWoundTreatment MR_findAllWithPredicate:predicate inContext:managedObjectContext];
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        [objectIDs addObjectsFromArray:[objects valueForKeyPath:@"objectID"]];
        while (YES) {
            predicate = [NSPredicate predicateWithFormat:@"parentTreatment IN (%@)", objects];
            objects = [WMWoundTreatment MR_findAllWithPredicate:predicate inContext:managedObjectContext];
            if ([objects count] == 0) {
                break;
            }
            // else
            [objectIDs addObjectsFromArray:[objects valueForKeyPath:@"objectID"]];
        }
        [self reportWoundTreatments:managedObjectContext];
        NSLog(@"*** WMWoundTreatment Hierarchy Report by objectID Begin ***");
        for (NSManagedObjectID *objectID in objectIDs) {
            WMWoundTreatment *woundTreatment = (WMWoundTreatment *)[managedObjectContext objectWithID:objectID];
            [self reportWoundTreatmentHierarchy:woundTreatment indent:0 recurs:NO];
        }
        NSLog(@"*** WMWoundTreatment Hierarchy Report by objectID End ***");
        completionHandler(nil, objectIDs, [WMWoundTreatment entityName], nil);
    }
}

+ (void)reportWoundTreatments:(NSManagedObjectContext *)managedObjectContext
{
    NSLog(@"*** WMWoundTreatment Hierarchy Report Begin ***");
    NSArray *rootWoundTreatments = [self sortedRootWoundTreatments:managedObjectContext];
    for (WMWoundTreatment *woundTreatment in rootWoundTreatments) {
        [self reportWoundTreatmentHierarchy:woundTreatment indent:0 recurs:YES];
    }
    NSLog(@"*** WMWoundTreatment Hierarchy Report End ***");
}

+ (void)reportWoundTreatmentHierarchy:(WMWoundTreatment *)woundTreatment indent:(NSInteger)indent recurs:(BOOL)recurs
{
    NSString *indentString = @"";
    for (int i=0; i<indent; ++i) {
        indentString = [indentString stringByAppendingString:@"\t"];
    }
    BOOL cyclicCheckFailed = NO;
    WMWoundTreatment *parentTreatment = woundTreatment.parentTreatment;
    while (parentTreatment) {
        if (woundTreatment.parentTreatment == woundTreatment) {
            cyclicCheckFailed = YES;
            break;
        }
        // else
        parentTreatment = parentTreatment.parentTreatment;
    }
    NSArray *childrenTreatments = [woundTreatment.childrenTreatments allObjects];
    NSMutableSet *set = [NSMutableSet set];
    for (WMWoundTreatment *childTreatment in childrenTreatments) {
        [childTreatment aggregateWoundTreatments:set];
        if ([set containsObject:woundTreatment]) {
            cyclicCheckFailed = YES;
            break;
        }
    }
    NSString *hasParent = (nil == woundTreatment.parentTreatment ? @"NO":@"YES");
    NSInteger childrenCount = [woundTreatment.childrenTreatments count];
    NSLog(@"%@WMWoundTreatment: %@ cyclic check failed: %@ has parent: %@ children count: %ld", indentString, woundTreatment.title, (cyclicCheckFailed ? @"YES":@"NO"), hasParent, (long)childrenCount);
    if (recurs) {
        for (WMWoundTreatment *childWoundTreatment in woundTreatment.childrenTreatments) {
            [self reportWoundTreatmentHierarchy:childWoundTreatment indent:(indent + 1) recurs:YES];
        }
    }
}

+ (NSPredicate *)predicateForParentTreatment:(WMWoundTreatment *)parentWoundTreatment woundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return [NSPredicate predicateWithFormat:@"parentTreatment == %@", parentWoundTreatment];
    }
    // else
    return [NSPredicate predicateWithFormat:@"parentTreatment == %@ AND (woundTypes.@count == 0 OR ANY woundTypes == %@)", parentWoundTreatment, woundType];
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"keyboardTypeValue",
                                                            @"snomedCIDValue",
                                                            @"sortRankValue",
                                                            @"valueTypeCodeValue",
                                                            @"valueMinimumValue",
                                                            @"valueMaximumValue",
                                                            @"groupValueTypeCode",
                                                            @"value",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"interventionEvents",
                                                            @"combineKeyAndValue",
                                                            @"allowMultipleChildSelection",
                                                            @"hasChildrenWoundTreatments",
                                                            @"sortedChildrenWoundTreatments",
                                                            @"childrenHaveSectionTitles",
                                                            @"skipSelectionIcon",
                                                            @"normalizeMeasurements",
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
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMWoundTreatmentRelationships.childrenTreatments,
                                                            WMWoundTreatmentRelationships.values]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMWoundTreatment attributeNamesNotToSerialize] containsObject:propertyName] || [[WMWoundTreatment relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundTreatment relationshipNamesNotToSerialize] containsObject:propertyName]) {
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

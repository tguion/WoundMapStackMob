#import "WMWoundMeasurement.h"
#import "WMWoundType.h"
#import "WMUtilities.h"

typedef enum {
    WoundMeasurementFlagsAllowMultipleChildSelection    = 0,
    WoundMeasurementFlagsNormalizeChildInputs           = 1,
} WoundMeasurementFlags;

NSString *const kWoundMeasurementTitleDimensions = @"Dimensions";

NSMutableArray *GraphableMeasurementTitles = nil;
NSMutableDictionary *MeasurementTitle2MinimumMaximumValues = nil;

@interface WMWoundMeasurement ()

// Private interface goes here.

@end


@implementation WMWoundMeasurement

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (BOOL)allowMultipleChildSelection
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundMeasurementFlagsAllowMultipleChildSelection];
}

- (void)setAllowMultipleChildSelection:(BOOL)allowMultipleChildSelection
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundMeasurementFlagsAllowMultipleChildSelection to:allowMultipleChildSelection]);
}

- (BOOL)normalizeMeasurements
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundMeasurementFlagsNormalizeChildInputs];
}

- (void)setNormalizeMeasurements:(BOOL)normalizeMeasurements
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundMeasurementFlagsNormalizeChildInputs to:normalizeMeasurements]);
}

- (BOOL)hasChildrenWoundMeasurements
{
    return [self.childrenMeasurements count] > 0;
}

- (BOOL)childrenHaveSectionTitles
{
    if (!self.hasChildrenWoundMeasurements) {
        return NO;
    }
    // else
    for (WMWoundMeasurement *woundMeasurement in self.childrenMeasurements) {
        if ([woundMeasurement.sectionTitle length] > 0) {
            return YES;
        }
    }
    // else
    return NO;
}

+ (NSArray *)sortedRootWoundMeasurements:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundMeasurement MR_findAllSortedBy:WMWoundMeasurementAttributes.sortRank ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"parentMeasurement = nil"] inContext:managedObjectContext];
}

+ (NSArray *)sortedRootGraphableWoundMeasurements:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundMeasurement MR_findAllSortedBy:WMWoundMeasurementAttributes.sortRank ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"parentMeasurement = nil AND graphableFlag == YES"] inContext:managedObjectContext];
}


+ (WMWoundMeasurement *)woundMeasureForTitle:(NSString *)title
                      parentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (parentWoundMeasurement) {
        NSParameterAssert([parentWoundMeasurement managedObjectContext] == managedObjectContext);
    }
    WMWoundMeasurement *woundMeasurement = [WMWoundMeasurement MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND parentMeasurement == %@", title, parentWoundMeasurement] inContext:managedObjectContext];
    if (create && nil == woundMeasurement) {
        woundMeasurement = [WMWoundMeasurement MR_createInContext:managedObjectContext];
        woundMeasurement.title = title;
        woundMeasurement.parentMeasurement = parentWoundMeasurement;
    }
    return woundMeasurement;
}

+ (WMWoundMeasurement *)dimensionsWoundMeasurement:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundMeasurement MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %d", kWoundMeasurementTitleDimensions] inContext:managedObjectContext];
}

+ (WMWoundMeasurement *)underminingTunnelingWoundMeasurement:(NSManagedObjectContext *)managedObjectContext
{
    return [WMWoundMeasurement MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"valueTypeCode == %d", GroupValueTypeCodeUndermineTunnel] inContext:managedObjectContext];
}

+ (WMWoundMeasurement *)updateWoundMeasurementFromDictionary:(NSDictionary *)dictionary
                                      parentWoundMeasurement:(WMWoundMeasurement *)parentWoundTreatment
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                   objectIDs:(NSMutableArray *)objectIDs
{
    id title = [dictionary objectForKey:@"title"];
    WMWoundMeasurement *measurement = [self woundMeasureForTitle:title
                                          parentWoundMeasurement:parentWoundTreatment
                                                          create:YES
                                            managedObjectContext:managedObjectContext];
    measurement.sortRank = [dictionary objectForKey:@"sortRank"];
    measurement.placeHolder = [dictionary objectForKey:@"placeHolder"];
    measurement.sectionTitle = [dictionary objectForKey:@"sectionTitle"];
    measurement.unit = [dictionary objectForKey:@"unit"];
    measurement.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
    measurement.keyboardType = [dictionary objectForKey:@"keyboardType"];
    measurement.allowMultipleChildSelection = [[dictionary objectForKey:@"allowMultipleChildSelection"] boolValue];
    measurement.normalizeMeasurements = [[dictionary objectForKey:@"normalizeMeasurements"] boolValue];
    measurement.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    measurement.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    measurement.loincCode = [dictionary objectForKey:@"LOINC Code"];
    measurement.graphableFlag = [dictionary objectForKey:@"graphableFlag"];
    id range = [dictionary objectForKey:@"range"];
    if ([range isKindOfClass:[NSString class]]) {
        // graphable range
        NSArray *minMaxValues = [range componentsSeparatedByString:@","];
        measurement.valueMinimum = [NSNumber numberWithInt:[[minMaxValues objectAtIndex:0] intValue]];
        measurement.valueMaximum = [NSNumber numberWithInt:[[minMaxValues objectAtIndex:1] intValue]];
    }
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
        [measurement setWoundTypes:set];
    }
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    NSAssert(![[measurement objectID] isTemporaryID], @"Expect a permanent objectID");
    [objectIDs addObject:[measurement objectID]];
    id measurements = [dictionary valueForKey:@"measurements"];
    if ([measurements isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in measurements) {
            [self updateWoundMeasurementFromDictionary:d
                                parentWoundMeasurement:measurement
                                  managedObjectContext:managedObjectContext
                                             objectIDs:objectIDs];
        }
    }
    return measurement;
}

+ (NSArray *)graphableMeasurementTitles
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GraphableMeasurementTitles = [[NSMutableArray alloc] init];
        // read the plist
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WoundMeasurement" withExtension:@"plist"];
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        for (NSDictionary *d in propertyList) {
            id graphableFlag = [d objectForKey:@"graphableFlag"];
            if (nil == graphableFlag) {
                continue;
            }
            // else
            [GraphableMeasurementTitles addObject:[d objectForKey:@"title"]];
        }
    });
    return GraphableMeasurementTitles;
}

+ (NSRange)graphableRangeForMeasurementTitle:(NSString *)title
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MeasurementTitle2MinimumMaximumValues = [[NSMutableDictionary alloc] init];
        // read the plist
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WoundMeasurement" withExtension:@"plist"];
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        for (NSDictionary *d in propertyList) {
            id range = [d objectForKey:@"range"];
            if (nil == range) {
                continue;
            }
            // else
            [MeasurementTitle2MinimumMaximumValues setValue:range forKey:[d objectForKey:@"title"]];
        }
    });
    NSString *range = [MeasurementTitle2MinimumMaximumValues objectForKey:title];
    return NSRangeFromString(range);
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WoundMeasurement" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"WoundMeasurement.plist file not found");
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
            [self updateWoundMeasurementFromDictionary:dictionary
                                parentWoundMeasurement:nil
                                  managedObjectContext:managedObjectContext
                                             objectIDs:objectIDs];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMWoundMeasurement entityName], nil);
        }
    }
}

+ (NSPredicate *)predicateForParentMeasurement:(WMWoundMeasurement *)parentWoundMeasurement woundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return [NSPredicate predicateWithFormat:@"parentMeasurement == %@", parentWoundMeasurement];
    }
    // else
    return [NSPredicate predicateWithFormat:@"parentMeasurement == %@ AND (woundTypes.@count == 0 OR ANY woundTypes == %@)", parentWoundMeasurement, woundType];
}

- (void)aggregateWoundMeasurements:(NSMutableSet *)set
{
    [set addObject:self];
    for (WMWoundMeasurement *woundMeasurement in self.childrenMeasurements) {
        [woundMeasurement aggregateWoundMeasurements:set];
    }
    [set unionSet:self.childrenMeasurements];
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"flagsValue",
                                                            @"graphableFlagValue",
                                                            @"keyboardTypeValue",
                                                            @"snomedCIDValue",
                                                            @"sortRankValue",
                                                            @"valueMaximumValue",
                                                            @"valueMinimumValue",
                                                            @"valueTypeCodeValue",
                                                            @"groupValueTypeCode",
                                                            @"unit",
                                                            @"value",
                                                            @"optionsArray",
                                                            @"secondaryOptionsArray",
                                                            @"interventionEvents",
                                                            @"allowMultipleChildSelection",
                                                            @"normalizeMeasurements",
                                                            @"hasChildrenWoundMeasurements",
                                                            @"childrenHaveSectionTitles"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMWoundMeasurementRelationships.childrenMeasurements,
                                                            WMWoundMeasurementRelationships.values]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMWoundMeasurement attributeNamesNotToSerialize] containsObject:propertyName] || [[WMWoundMeasurement relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundMeasurement relationshipNamesNotToSerialize] containsObject:propertyName]) {
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

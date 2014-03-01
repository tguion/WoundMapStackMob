#import "WMWoundMeasurement.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

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

- (BOOL)allowMultipleChildSelection
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundMeasurementFlagsAllowMultipleChildSelection];
}

- (void)setAllowMultipleChildSelection:(BOOL)allowMultipleChildSelection
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundMeasurementFlagsAllowMultipleChildSelection to:allowMultipleChildSelection]];
}

- (BOOL)normalizeMeasurements
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundMeasurementFlagsNormalizeChildInputs];
}

- (void)setNormalizeMeasurements:(BOOL)normalizeMeasurements
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundMeasurementFlagsNormalizeChildInputs to:normalizeMeasurements]];
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


+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMWoundMeasurement *woundMeasurement = [[WMWoundMeasurement alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundMeasurement" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundMeasurement toPersistentStore:store];
	}
    [woundMeasurement setValue:[woundMeasurement assignObjectId] forKey:[woundMeasurement primaryKeyField]];
	return woundMeasurement;
}

+ (NSArray *)sortedRootWoundMeasurements:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurement" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parentMeasurement = nil"]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

+ (NSArray *)sortedRootGraphableWoundMeasurements:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurement" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parentMeasurement = nil AND graphableFlag == YES"]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}


+ (WMWoundMeasurement *)woundMeasureForTitle:(NSString *)title
                      parentWoundMeasurement:(WMWoundMeasurement *)parentWoundMeasurement
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurement" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND parentMeasurement == %@", title, parentWoundMeasurement]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundMeasurement *woundMeasurement = [array lastObject];
    if (create && nil == woundMeasurement) {
        woundMeasurement = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        woundMeasurement.title = title;
        woundMeasurement.parentMeasurement = parentWoundMeasurement;
    }
    return woundMeasurement;
}

+ (WMWoundMeasurement *)dimensionsWoundMeasurement:(NSManagedObjectContext *)managedObjectContext
                                   persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurement" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %d", kWoundMeasurementTitleDimensions]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (WMWoundMeasurement *)underminingTunnelingWoundMeasurement:(NSManagedObjectContext *)managedObjectContext
                                             persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundMeasurement" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"valueTypeCode == %d", GroupValueTypeCodeUndermineTunnel]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (WMWoundMeasurement *)updateWoundMeasurementFromDictionary:(NSDictionary *)dictionary
                                      parentWoundMeasurement:(WMWoundMeasurement *)parentWoundTreatment
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                             persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMWoundMeasurement *measurement = [self woundMeasureForTitle:title
                                          parentWoundMeasurement:parentWoundTreatment
                                                          create:YES
                                            managedObjectContext:managedObjectContext
                                                 persistentStore:store];
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
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store];
            [set addObjectsFromArray:woundTypes];
        }
        [measurement setWoundTypes:set];
    }
    id measurements = [dictionary valueForKey:@"measurements"];
    if ([measurements isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in measurements) {
            [self updateWoundMeasurementFromDictionary:d
                                parentWoundMeasurement:measurement
                                  managedObjectContext:managedObjectContext
                                       persistentStore:store];
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

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
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
        for (NSDictionary *dictionary in propertyList) {
            [self updateWoundMeasurementFromDictionary:dictionary parentWoundMeasurement:nil managedObjectContext:managedObjectContext persistentStore:store];
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

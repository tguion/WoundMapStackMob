#import "WMWoundTreatment.h"
#import "WMWoundTreatmentValue.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

typedef enum {
    WoundTreatmentFlagsInputValueInline             = 0,
    WoundTreatmentFlagsAllowMultipleChildSelection  = 1,
    WoundTreatmentFlagsOtherFlag                    = 2,
    WoundTreatmentFlagsCombineKeyAndValue           = 3,
    WoundTreatmentFlagsSkipSelectionIcon            = 4,
} WoundTreatmentFlags;


@interface WMWoundTreatment ()

// Private interface goes here.

@end


@implementation WMWoundTreatment

- (BOOL)combineKeyAndValue
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsCombineKeyAndValue];
}

- (void)setCombineKeyAndValue:(BOOL)combineKeyAndValue
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsCombineKeyAndValue to:combineKeyAndValue]];
}

- (BOOL)allowMultipleChildSelection
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsAllowMultipleChildSelection];
}

- (void)setAllowMultipleChildSelection:(BOOL)allowMultipleChildrenSelection
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsAllowMultipleChildSelection to:allowMultipleChildrenSelection]];
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
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundTreatmentFlagsSkipSelectionIcon to:skipSelectionIcon]];
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

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundTreatment *woundTreatment = [[WMWoundTreatment alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundTreatment" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundTreatment toPersistentStore:store];
	}
    [woundTreatment setValue:[woundTreatment assignObjectId] forKey:[woundTreatment primaryKeyField]];
	return woundTreatment;
}

+ (WMWoundTreatment *)woundTreatmentForTitle:(NSString *)title
                        parentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundTreatment" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND parentTreatment == %@", title, parentWoundTreatment]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundTreatment *woundTreatment = [array lastObject];
    if (create && nil == woundTreatment) {
        woundTreatment = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        woundTreatment.title = title;
        woundTreatment.parentTreatment = parentWoundTreatment;
    }
    return woundTreatment;
}

+ (NSArray *)sortedRootWoundTreatments:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundTreatment" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parentTreatment = nil"]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return array;
}

+ (WMWoundTreatment *)updateWoundTreatmentFromDictionary:(NSDictionary *)dictionary
                                    parentWoundTreatment:(WMWoundTreatment *)parentWoundTreatment
                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                         persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMWoundTreatment *treatment = [self woundTreatmentForTitle:title
                                          parentWoundTreatment:parentWoundTreatment
                                                        create:YES
                                          managedObjectContext:managedObjectContext
                                               persistentStore:store];
    treatment.sortRank = [dictionary objectForKey:@"sortRank"];
    treatment.placeHolder = [dictionary objectForKey:@"placeHolder"];
    treatment.sectionTitle = [dictionary objectForKey:@"sectionTitle"];
    treatment.unit = [dictionary objectForKey:@"unit"];
    treatment.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
    treatment.keyboardType = [dictionary objectForKey:@"keyboardType"];
    treatment.combineKeyAndValue = [[dictionary objectForKey:@"combineKeyAndValue"] boolValue];
    treatment.allowMultipleChildSelection = [[dictionary objectForKey:@"allowMultipleChildSelection"] boolValue];
    treatment.skipSelectionIcon = [[dictionary objectForKey:@"skipSelectionIcon"] boolValue];
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
                                                     managedObjectContext:managedObjectContext
                                                          persistentStore:store];
            [set addObjectsFromArray:woundTypes];
        }
        [treatment setWoundTypes:set];
    }
    id children = [dictionary valueForKey:@"children"];
    if ([children isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in children) {
            [self updateWoundTreatmentFromDictionary:d
                                parentWoundTreatment:treatment
                                managedObjectContext:managedObjectContext
                                     persistentStore:store];
        }
    }
    return treatment;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WoundTreatment" withExtension:@"plist"];
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
                                managedObjectContext:managedObjectContext
                                     persistentStore:store];
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

#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

NSString * const kOtherWoundTypeTitle = @"Other";

@interface WMWoundType ()

// Private interface goes here.

@end


@implementation WMWoundType

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

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundType *woundType = [[WMWoundType alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundType" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundType toPersistentStore:store];
	}
    [woundType setValue:[woundType assignObjectId] forKey:[woundType primaryKeyField]];
    // get a permanent objectID
    NSError *error = nil;
    if (![managedObjectContext obtainPermanentIDsForObjects:@[woundType] error:&error]) {
        DLog(@"Couldn't obtain a permanent ID for object %@", error);
    }
	return woundType;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"WoundType" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"WoundType.plist file not found");
		return;
	}
    // else see if seeded
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundType" inManagedObjectContext:managedObjectContext]];
    NSInteger count = [managedObjectContext countForFetchRequestAndWait:request error:&error];
    if (count > 0 && count != NSNotFound) {
        return;
    }
    // else
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an NSArray, class was %@", NSStringFromClass([propertyList class]));
        for (NSDictionary *dictionary in propertyList) {
            [self updateWoundTypeFromDictionary:dictionary managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

+ (WMWoundType *)updateWoundTypeFromDictionary:(NSDictionary *)dictionary
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMWoundType *woundType = [WMWoundType woundTypeForTitle:title
                                                     create:YES
                                       managedObjectContext:managedObjectContext
                                            persistentStore:store];
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
    id children = [dictionary objectForKey:@"children"];
    if ([children isKindOfClass:[NSArray class]]) {
        for (NSDictionary *d in children) {
            [woundType addChildrenObject:[self updateWoundTypeFromDictionary:d managedObjectContext:managedObjectContext persistentStore:store]];
        }
    }
    return woundType;
}

+ (WMWoundType *)woundTypeForTitle:(NSString *)title
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                   persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundType" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMWoundType *woundType = [array lastObject];
    if (create && nil == woundType) {
        woundType = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        woundType.title = title;
    }
    return woundType;
}

+ (NSArray *)woundTypesForWoundTypeCode:(NSInteger)woundTypeCodeValue
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundType" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"woundTypeCode == %d", woundTypeCodeValue]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    return array;
}

+ (WMWoundType *)otherWoundType:(NSManagedObjectContext *)managedObjectContext
                persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundType" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", kOtherWoundTypeTitle]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    return [array lastObject];
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

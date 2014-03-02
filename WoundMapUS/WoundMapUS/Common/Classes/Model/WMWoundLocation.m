#import "WMWoundLocation.h"
#import "WMWoundPosition.h"
#import "WMWoundLocationPositionJoin.h"
#import "WMUtilities.h"
#import "StackMob.h"

NSString * const kOtherWoundLocationTitle = @"Other";


@interface WMWoundLocation ()

// Private interface goes here.

@end


@implementation WMWoundLocation

- (BOOL)isOther
{
    return [kOtherWoundLocationTitle isEqualToString:self.title];
}

- (NSArray *)sortedWoundPositionJoins
{
    return [[self.positionJoins allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMWoundLocation *woundLocation = [[WMWoundLocation alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundLocation" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundLocation toPersistentStore:store];
	}
    [woundLocation setValue:[woundLocation assignObjectId] forKey:[woundLocation primaryKeyField]];
	return woundLocation;
}

+ (WMWoundLocation *)woundLocationForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                           persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundLocation" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMWoundLocation *woundLocation = [array lastObject];
    if (create && nil == woundLocation) {
        woundLocation = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        woundLocation.title = title;
    }
    return woundLocation;
}

+ (WMWoundLocation *)otherWoundLocation:(NSManagedObjectContext *)managedObjectContext
                        persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMWoundLocation" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", kOtherWoundLocationTitle]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

#pragma mark - Seed

+ (void)updateWoundLocationsFromArray:(NSArray *)locations
                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                      persistentStore:(NSPersistentStore *)store
{
    for (NSDictionary *dictionary in locations) {
        id title = [dictionary objectForKey:@"title"];
        WMWoundLocation *location = [self woundLocationForTitle:title
                                                         create:YES
                                           managedObjectContext:managedObjectContext
                                                persistentStore:store];
        location.definition = [dictionary objectForKey:@"definition"];
        location.loincCode = [dictionary objectForKey:@"LOINC Code"];
        location.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
        location.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
        location.sortRank = [dictionary objectForKey:@"sortRank"];
        location.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
        location.placeHolder = [dictionary objectForKey:@"placeHolder"];
        title = [dictionary objectForKey:@"sectionTitle"];
        if (nil == title) {
            title = @"Other Locations";
        }
        location.sectionTitle = title;
    }
}

+ (void)updateWoundLocationQualifiersFromArray:(NSArray *)qualifiers
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               persistentStore:(NSPersistentStore *)store
{
    for (NSDictionary *dictionary in qualifiers) {
        id title = [dictionary objectForKey:@"title"];
        WMWoundPosition *position = [WMWoundPosition woundPositionForTitle:title
                                                                    create:YES
                                                      managedObjectContext:managedObjectContext
                                                           persistentStore:store];
        position.commonTitle = [dictionary objectForKey:@"common title"];
        position.prompt = [dictionary objectForKey:@"prompt"];
        position.definition = [dictionary objectForKey:@"definition"];
        position.loincCode = [dictionary objectForKey:@"LOINC Code"];
        position.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
        position.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
        position.sortRank = [dictionary objectForKey:@"sortRank"];
        position.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
    }
}

+ (void)updateLocationQualifierJoinsFromArray:(NSArray *)joins
                         managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                              persistentStore:(NSPersistentStore *)store
{
    for (NSDictionary *dictionary in joins) {
        id locationTitle = [dictionary objectForKey:@"location"];
        WMWoundLocation *location = [self woundLocationForTitle:locationTitle
                                                         create:NO
                                           managedObjectContext:managedObjectContext
                                                persistentStore:store];
        NSAssert1(nil != location, @"Location not found for title %@", locationTitle);
        id positionGroups =[[dictionary objectForKey:@"groups"] componentsSeparatedByString:@"|"];
        NSInteger sortRank = 0;
        for (NSString *positionOptions in positionGroups) {
            id positionTitles = [positionOptions componentsSeparatedByString:@","];
            NSMutableSet *positions = [[NSMutableSet alloc] initWithCapacity:16];
            for (NSString *positionTitle in positionTitles) {
                WMWoundPosition *position = [WMWoundPosition woundPositionForTitle:positionTitle
                                                                            create:NO
                                                              managedObjectContext:managedObjectContext
                                                                   persistentStore:store];
                NSAssert1(nil != position, @"Position not found for title %@", positionTitle);
                [positions addObject:position];
            }
            WMWoundLocationPositionJoin *join = [WMWoundLocationPositionJoin joinForLocation:location
                                                                                   positions:positions
                                                                                      create:YES
                                                                        managedObjectContext:managedObjectContext
                                                                             persistentStore:store];
            join.sortRank = [NSNumber numberWithInt:sortRank++];
        }
    }
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"AnatomicLocation" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"AnatomicLocation.plist file not found");
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
        NSAssert1([propertyList isKindOfClass:[NSDictionary class]], @"Property list file did not return an NSDictionary, class was %@", NSStringFromClass([propertyList class]));
        id locations = [propertyList objectForKey:@"Location"];
        NSAssert1([locations isKindOfClass:[NSArray class]], @"Location is not an NSArray, class was %@", NSStringFromClass([locations class]));
        [self updateWoundLocationsFromArray:locations managedObjectContext:managedObjectContext persistentStore:store];
        id qualifiers = [propertyList objectForKey:@"Qualifier"];
        NSAssert1([qualifiers isKindOfClass:[NSArray class]], @"Qualifier is not an NSArray, class was %@", NSStringFromClass([locations class]));
        [self updateWoundLocationQualifiersFromArray:qualifiers managedObjectContext:managedObjectContext persistentStore:store];
        id joins = [propertyList objectForKey:@"Joins"];
        NSAssert1([joins isKindOfClass:[NSArray class]], @"Joins is not an NSArray, class was %@", NSStringFromClass([locations class]));
        [self updateLocationQualifierJoinsFromArray:joins managedObjectContext:managedObjectContext persistentStore:store];
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

@end

#import "WMMedicationCategory.h"
#import "WMMedication.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMMedicationCategory ()

// Private interface goes here.

@end


@implementation WMMedicationCategory

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMMedicationCategory *medicationCategory = [[WMMedicationCategory alloc] initWithEntity:[NSEntityDescription entityForName:@"WMMedicationCategory" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:medicationCategory toPersistentStore:store];
	}
    [medicationCategory setValue:[medicationCategory assignObjectId] forKey:[medicationCategory primaryKeyField]];
	return medicationCategory;
}

+ (WMMedicationCategory *)medicationCategoryForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                     persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMMedicationCategory" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMMedicationCategory *medicationCategory = [array lastObject];
    if (create && nil == medicationCategory) {
        medicationCategory = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        medicationCategory.title = title;
    }
    return medicationCategory;
}

+ (WMMedicationCategory *)medicationCategoryForSortRank:(id)sortRank
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                        persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMMedicationCategory" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"sortRank == %@", sortRank]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (WMMedicationCategory *)updateMedicationCategoryFromDictionary:(NSDictionary *)dictionary
                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                 persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMMedicationCategory *medicationCategory = [self medicationCategoryForTitle:title
                                                                         create:YES
                                                           managedObjectContext:managedObjectContext
                                                                persistentStore:store];
    medicationCategory.definition = [dictionary objectForKey:@"definition"];
    medicationCategory.loincCode = [dictionary objectForKey:@"LOINC Code"];
    medicationCategory.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    medicationCategory.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    medicationCategory.sortRank = [dictionary objectForKey:@"sortRank"];
    // IAP: check if category is associated with IAP
    id iapIdentifier = [dictionary objectForKey:@"iapIdentifier"];
    if (nil != iapIdentifier) {
        medicationCategory.iapIdentifier = iapIdentifier;
    }
    // restricting to medication category, not medication - create separate categories for each wound type
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
        [medicationCategory setWoundTypes:set];
    }
    // now medications
    id medications = [dictionary objectForKey:@"Medications"];
    for (NSDictionary *d in medications) {
        WMMedication *medication = [WMMedication updateMedicationFromDictionary:d managedObjectContext:managedObjectContext persistentStore:store];
        medication.category = medicationCategory;
    }
    return medicationCategory;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Medications" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"Medications.plist file not found");
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
            [self updateMedicationCategoryFromDictionary:dictionary managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

@end

#import "WMSkinAssessmentCategory.h"
#import "WMSkinAssessment.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMSkinAssessmentCategory ()

// Private interface goes here.

@end


@implementation WMSkinAssessmentCategory

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMSkinAssessmentCategory *skinInspectionCategory = [[WMSkinAssessmentCategory alloc] initWithEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentCategory" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:skinInspectionCategory toPersistentStore:store];
	}
    [skinInspectionCategory setValue:[skinInspectionCategory assignObjectId] forKey:[skinInspectionCategory primaryKeyField]];
	return skinInspectionCategory;
}

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForTitle:(NSString *)title
                                                      create:(BOOL)create
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                             persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentCategory" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMSkinAssessmentCategory *skinInspectionCategory = [array lastObject];
    if (create && nil == skinInspectionCategory) {
        skinInspectionCategory = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        skinInspectionCategory.title = title;
    }
    return skinInspectionCategory;
}

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForSortRank:(id)sortRank
                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentCategory" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"sortRank == %@", sortRank]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return [array lastObject];
}

+ (WMSkinAssessmentCategory *)updateSkinAssessmentCategoryFromDictionary:(NSDictionary *)dictionary
                                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                                         persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMSkinAssessmentCategory *skinInspectionCategory = [self skinAssessmentCategoryForTitle:title
                                                                                     create:YES
                                                                       managedObjectContext:managedObjectContext
                                                                            persistentStore:store];
    skinInspectionCategory.definition = [dictionary objectForKey:@"definition"];
    skinInspectionCategory.loincCode = [dictionary objectForKey:@"LOINC Code"];
    skinInspectionCategory.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    skinInspectionCategory.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    skinInspectionCategory.sortRank = [dictionary objectForKey:@"sortRank"];
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
        [skinInspectionCategory setWoundTypes:set];
    }
    // now inspections
    id inspections = [dictionary objectForKey:@"options"];
    for (NSDictionary *d in inspections) {
        WMSkinAssessment *inspection = [WMSkinAssessment updateSkinAssessmentFromDictionary:d
                                                                                   category:skinInspectionCategory
                                                                       managedObjectContext:managedObjectContext
                                                                            persistentStore:store];
        inspection.category = skinInspectionCategory;
    }
    return skinInspectionCategory;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
	NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"SkinAssessment" withExtension:@"plist"];
	if (nil == fileURL) {
		DLog(@"SkinAssessment.plist file not found");
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
            [self updateSkinAssessmentCategoryFromDictionary:dictionary managedObjectContext:managedObjectContext persistentStore:store];
        }
    }
}

@end

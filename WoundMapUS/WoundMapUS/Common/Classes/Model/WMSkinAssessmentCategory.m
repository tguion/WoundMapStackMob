#import "WMSkinAssessmentCategory.h"
#import "WMSkinAssessment.h"
#import "WMWoundType.h"
#import "WMUtilities.h"

@interface WMSkinAssessmentCategory ()

// Private interface goes here.

@end


@implementation WMSkinAssessmentCategory

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForTitle:(NSString *)title
                                                      create:(BOOL)create
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMSkinAssessmentCategory *skinInspectionCategory = [WMSkinAssessmentCategory MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == skinInspectionCategory) {
        skinInspectionCategory = [WMSkinAssessmentCategory MR_createInContext:managedObjectContext];
        skinInspectionCategory.title = title;
    }
    return skinInspectionCategory;
}

+ (WMSkinAssessmentCategory *)skinAssessmentCategoryForSortRank:(id)sortRank
                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMSkinAssessmentCategory MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"sortRank == %@", sortRank] inContext:managedObjectContext];
}

+ (WMSkinAssessmentCategory *)updateSkinAssessmentCategoryFromDictionary:(NSDictionary *)dictionary
                                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id title = [dictionary objectForKey:@"title"];
    WMSkinAssessmentCategory *skinInspectionCategory = [self skinAssessmentCategoryForTitle:title
                                                                                     create:YES
                                                                       managedObjectContext:managedObjectContext];
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
                                                     managedObjectContext:managedObjectContext];
            [set addObjectsFromArray:woundTypes];
        }
        [skinInspectionCategory setWoundTypes:set];
    }
    // now inspections
    id inspections = [dictionary objectForKey:@"options"];
    for (NSDictionary *d in inspections) {
        WMSkinAssessment *inspection = [WMSkinAssessment updateSkinAssessmentFromDictionary:d
                                                                                   category:skinInspectionCategory
                                                                       managedObjectContext:managedObjectContext];
        inspection.category = skinInspectionCategory;
    }
    return skinInspectionCategory;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler
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
        NSMutableArray *objectIDs = [[NSMutableArray alloc] init];
        for (NSDictionary *dictionary in propertyList) {
            WMSkinAssessmentCategory *skinInspectionCategory = [self updateSkinAssessmentCategoryFromDictionary:dictionary managedObjectContext:managedObjectContext];
            [managedObjectContext MR_saveOnlySelfAndWait];
            NSAssert(![[skinInspectionCategory objectID] isTemporaryID], @"Expect a permanent objectID");
            [objectIDs addObject:[skinInspectionCategory objectID]];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        if (completionHandler) {
            completionHandler(nil, objectIDs, [WMSkinAssessmentCategory entityName]);
        }
    }
}

@end

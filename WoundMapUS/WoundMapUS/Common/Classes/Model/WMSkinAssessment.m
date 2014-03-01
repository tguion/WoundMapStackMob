#import "WMSkinAssessment.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMSkinAssessment ()

// Private interface goes here.

@end


@implementation WMSkinAssessment

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMSkinAssessment *skinInspection = [[WMSkinAssessment alloc] initWithEntity:[NSEntityDescription entityForName:@"WMSkinAssessment" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:skinInspection toPersistentStore:store];
	}
    [skinInspection setValue:[skinInspection assignObjectId] forKey:[skinInspection primaryKeyField]];
	return skinInspection;
}

+ (WMSkinAssessment *)skinInspectionForTitle:(NSString *)title
                                    category:(WMSkinAssessmentCategory *)category
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMSkinAssessment" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@ AND category == %@", title, category]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMSkinAssessment *skinInspection = [array lastObject];
    if (create && nil == skinInspection) {
        skinInspection = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        skinInspection.title = title;
    }
    return skinInspection;
}

+ (WMSkinAssessment *)updateSkinAssessmentFromDictionary:(NSDictionary *)dictionary
                                                category:(WMSkinAssessmentCategory *)category
                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                         persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMSkinAssessment *skinInspection = [self skinInspectionForTitle:title
                                                           category:category
                                                             create:YES
                                               managedObjectContext:managedObjectContext
                                                    persistentStore:store];
    skinInspection.definition = [dictionary objectForKey:@"definition"];
    skinInspection.loincCode = [dictionary objectForKey:@"LOINC Code"];
    skinInspection.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    skinInspection.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    skinInspection.sortRank = [dictionary objectForKey:@"sortRank"];
    skinInspection.label = [dictionary objectForKey:@"label"];
    skinInspection.options = [dictionary objectForKey:@"options"];
    skinInspection.placeHolder = [dictionary objectForKey:@"placeHolder"];
    skinInspection.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
    return skinInspection;
}

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return nil;
    }
    // else
    return [NSPredicate predicateWithFormat:@"category.woundTypes.@count == 0 OR ANY category.woundTypes == %@", woundType];
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

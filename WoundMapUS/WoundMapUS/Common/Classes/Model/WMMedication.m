#import "WMMedication.h"
#import "WMWoundType.h"
#import "WMUtilities.h"
#import "StackMob.h"

typedef enum {
    WMMedicationExludeOtherValues             = 0,
} WMMedicationFlags;

@interface WMMedication ()

// Private interface goes here.

@end


@implementation WMMedication

- (BOOL)exludesOtherValues
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WMMedicationExludeOtherValues];
}

- (void)setExludesOtherValues:(BOOL)exludesOtherValues
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WMMedicationExludeOtherValues to:exludesOtherValues]];
}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMMedication *medication = [[WMMedication alloc] initWithEntity:[NSEntityDescription entityForName:@"WMMedication" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:medication toPersistentStore:store];
	}
    [medication setValue:[medication assignObjectId] forKey:[medication primaryKeyField]];
	return medication;
}

+ (WMMedication *)medicationForTitle:(NSString *)title
                              create:(BOOL)create
                managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                     persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMMedication" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMMedication *medication = [array lastObject];
    if (create && nil == medication) {
        medication = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        medication.title = title;
    }
    return medication;
}

+ (WMMedication *)updateMedicationFromDictionary:(NSDictionary *)dictionary
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMMedication *medication = [self medicationForTitle:title
                                                 create:YES
                                   managedObjectContext:managedObjectContext
                                        persistentStore:store];
    medication.definition = [dictionary objectForKey:@"definition"];
    medication.loincCode = [dictionary objectForKey:@"LOINC Code"];
    medication.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    medication.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    medication.sortRank = [dictionary objectForKey:@"sortRank"];
    medication.exludesOtherValues = [[dictionary objectForKey:@"exludesOtherValues"] boolValue];
    return medication;
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
    return GroupValueTypeCodeSelect;
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

- (NSString *)placeHolder
{
    return nil;
}

- (void)setPlaceHolder:(NSString *)placeHolder
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

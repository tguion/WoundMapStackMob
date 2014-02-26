#import "WMDevice.h"
#import "WMUtilities.h"
#import "StackMob.h"

typedef enum {
    WCDeviceExludeOtherValues             = 0,
} WMDeviceFlags;

@interface WMDevice ()

// Private interface goes here.

@end


@implementation WMDevice

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMDevice *device = [[WMDevice alloc] initWithEntity:[NSEntityDescription entityForName:@"WMDevice" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:device toPersistentStore:store];
	}
    [device setValue:[device assignObjectId] forKey:[device primaryKeyField]];
	return device;
}

+ (WMDevice *)deviceForTitle:(NSString *)title
                      create:(BOOL)create
        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
             persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMDevice" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMDevice *device = [array lastObject];
    if (create && nil == device) {
        device = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        device.title = title;
    }
    return device;
}

+ (WMDevice *)updateDeviceFromDictionary:(NSDictionary *)dictionary
                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                         persistentStore:(NSPersistentStore *)store
{
    id title = [dictionary objectForKey:@"title"];
    WMDevice *device = [self deviceForTitle:title
                                     create:YES
                       managedObjectContext:managedObjectContext
                            persistentStore:store];
    device.definition = [dictionary objectForKey:@"definition"];
    device.loincCode = [dictionary objectForKey:@"LOINC Code"];
    device.snomedCID = [dictionary objectForKey:@"SNOMED CT CID"];
    device.snomedFSN = [dictionary objectForKey:@"SNOMED CT FSN"];
    device.sortRank = [dictionary objectForKey:@"sortRank"];
    device.label = [dictionary objectForKey:@"label"];
    device.options = [dictionary objectForKey:@"options"];
    device.placeHolder = [dictionary objectForKey:@"placeHolder"];
    device.valueTypeCode = [dictionary objectForKey:@"inputTypeCode"];
    device.exludesOtherValues = [[dictionary objectForKey:@"exludesOtherValues"] boolValue];
    return device;
}

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType
{
    if (nil == woundType) {
        return nil;
    }
    // else include all WMDevice instances where category has no woundTypes OR has wound type included
    // !(ANY excludedOccurrences.start >= %@ AND ANY excludedOccurrences.start <= %@)
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE excludedDay.day == %@", today];
    return [NSPredicate predicateWithFormat:@"category.woundTypes.@count == 0 OR ANY category.woundTypes == %@", woundType];
}

- (BOOL)exludesOtherValues
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WCDeviceExludeOtherValues];
}

- (void)setExludesOtherValues:(BOOL)exludesOtherValues
{
    self.flags = [NSNumber numberWithInt:[WMUtilities updateBitForValue:[self.flags intValue] atPosition:WCDeviceExludeOtherValues to:exludesOtherValues]];
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

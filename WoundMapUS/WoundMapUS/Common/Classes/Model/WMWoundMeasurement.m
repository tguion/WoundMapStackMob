#import "WMWoundMeasurement.h"
#import "WoundCareProtocols.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMWoundMeasurement ()

// Private interface goes here.

@end


@implementation WMWoundMeasurement

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

@end

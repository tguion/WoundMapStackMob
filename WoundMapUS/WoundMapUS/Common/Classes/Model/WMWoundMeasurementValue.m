#import "WMWoundMeasurementValue.h"
#import "StackMob.h"


@interface WMWoundMeasurementValue ()

// Private interface goes here.

@end


@implementation WMWoundMeasurementValue

+ (instancetype)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                 persistentStore:(NSPersistentStore *)store
{
    WMWoundMeasurementValue *woundMeasurementValue = [[WMWoundMeasurementValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:woundMeasurementValue toPersistentStore:store];
	}
    [woundMeasurementValue setValue:[woundMeasurementValue assignObjectId] forKey:[woundMeasurementValue primaryKeyField]];
	return woundMeasurementValue;
}

@end
